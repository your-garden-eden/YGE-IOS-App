import Foundation
import FirebaseFunctions

enum FirebaseError: Error {
    case functionsError(Error) // Underlying Functions error
    case dataSerializationError(Error) // Error converting Firebase response to Data for JSONDecoder
    case decodingError(Error) // Error decoding JSON to ResponseData
    case noData // Firebase returned success but no data payload
    case operationCancelled
    case resultIsNotJSON // Firebase returned data, but it's not in a format we can serialize to JSON data
}

class FirebaseProxyService {
    static let shared = FirebaseProxyService()
    private lazy var functions = Functions.functions(region: "europe-west1") // Deine Region

    private init() {}

    func callFunction<RequestData: Encodable, ResponseData: Decodable>(
        functionName: String,
        requestDataObject: RequestData?, // Renamed for clarity
        completion: @escaping (Result<ResponseData, FirebaseError>) -> Void
    ) {
        // Encode RequestData to a suitable format if it's not nil
        // Firebase expects an Any type for parameters.
        // If RequestData is a struct/class, convert it to a dictionary.
        // If RequestData is a simple type (String, Int), it can be passed directly.
        // For complex Encodable types, it's common to serialize to [String: Any]
        
        var parameters: Any? = nil
        if let requestDataObject = requestDataObject {
            do {
                // Convert Encodable to Data, then Data to [String: Any] or [[String: Any]]
                let jsonData = try JSONEncoder().encode(requestDataObject)
                parameters = try JSONSerialization.jsonObject(with: jsonData, options: [])
            } catch {
                print("Failed to encode RequestData for \(functionName): \(error)")
                completion(.failure(.dataSerializationError(error))) // Or a new .encodingError
                return
            }
        }

        functions.httpsCallable(functionName).call(parameters) { result, error in
            if let error = error {
                let nsError = error as NSError
                if nsError.domain == FunctionsErrorDomain && FunctionsErrorCode(rawValue: nsError.code) == .cancelled {
                    completion(.failure(.operationCancelled))
                } else {
                    completion(.failure(.functionsError(error)))
                }
                return
            }

            guard let responsePayload = result?.data else {
                completion(.failure(.noData))
                return
            }
            
            // Now, responsePayload is Any. We need to convert it to Data for JSONDecoder.
            // This assumes the Cloud Function returns JSON.
            let jsonData: Data
            do {
                // If responsePayload is already Data (e.g. for raw bytes, less common for JSON APIs)
                // For most JSON-returning functions, responsePayload will be NSDictionary or NSArray.
                if responsePayload is Data { // Should not happen for JSON
                    jsonData = responsePayload as! Data // Risky, Firebase usually gives structured types for JSON
                     print("Warning: Firebase function '\(functionName)' returned raw Data, not typical for JSON.")
                } else if JSONSerialization.isValidJSONObject(responsePayload) {
                    jsonData = try JSONSerialization.data(withJSONObject: responsePayload, options: [])
                }
                // Handle if the function returns a simple String that is NOT JSON.
                // This case is tricky. If your API sometimes returns plain strings and sometimes JSON,
                // the ResponseData type needs to reflect that, or you need separate functions.
                // For now, we assume JSON.
                else if let stringPayload = responsePayload as? String {
                    // If you expect a JSON string, convert it to Data
                    // If you expect a non-JSON string, ResponseData should be String, and decoding will fail.
                    // This path is ambiguous without knowing what ResponseData expects.
                    // Let's assume if it's a string, it's a JSON string.
                    guard let dataFromString = stringPayload.data(using: .utf8) else {
                        print("Error: Could not convert string response to Data for \(functionName). String: \(stringPayload)")
                        completion(.failure(.resultIsNotJSON)) // Or a more specific error
                        return
                    }
                    jsonData = dataFromString
                }
                else {
                     print("Error: Firebase function '\(functionName)' returned data that is not a valid JSON object or string. Type: \(type(of: responsePayload))")
                    completion(.failure(.resultIsNotJSON))
                    return
                }
            } catch {
                print("Error serializing Firebase response to JSON Data for \(functionName): \(error)")
                completion(.failure(.dataSerializationError(error)))
                return
            }

            // Now jsonData is definitely Data, try to decode
            do {
                let decoder = JSONDecoder()
                // Configure your decoder as needed (e.g., dateStrategy, keyDecodingStrategy)
                // decoder.keyDecodingStrategy = .convertFromSnakeCase
                let responseObject = try decoder.decode(ResponseData.self, from: jsonData)
                completion(.success(responseObject))
            } catch {
                print("Failed to decode JSON response for \(functionName) into \(String(describing: ResponseData.self)). Error: \(error)")
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Raw JSON data being decoded: \(jsonString)")
                } else {
                    print("Raw JSON data could not be represented as a UTF-8 string.")
                }
                completion(.failure(.decodingError(error)))
            }
        }
    }
}
