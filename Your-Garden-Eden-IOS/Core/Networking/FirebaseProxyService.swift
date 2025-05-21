import Foundation
import FirebaseFunctions

class FirebaseProxyService {
    private lazy var functions = Functions.functions(region: "europe-west1")
    static let shared = FirebaseProxyService()

    enum ProxyServiceError: Error, LocalizedError {
        case noDataReceived
        case encodingRequestDataFailed(Error)
        case decodingError(Error)
        case functionError(Error)
        case unknownError

        var errorDescription: String? {
            switch self {
            case .noDataReceived: return "No data was received from the server function."
            case .encodingRequestDataFailed(let error): return "Failed to prepare request data: \(error.localizedDescription)"
            case .decodingError(let error):
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        return "Decoding Error: Type mismatch for \(type) - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                    case .valueNotFound(let type, let context):
                        return "Decoding Error: Value not found for \(type) - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                    case .keyNotFound(let key, let context):
                        return "Decoding Error: Key '\(key.stringValue)' not found - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                    case .dataCorrupted(let context):
                        return "Decoding Error: Data corrupted - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                    @unknown default:
                        return "Failed to decode response: An unknown decoding error occurred."
                    }
                }
                return "Failed to decode response: \(error.localizedDescription)"
            case .functionError(let error):
                let nsError = error as NSError
                if nsError.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: nsError.code) ?? .unknown
                    let message = nsError.userInfo[FunctionsErrorDetailsKey] as? String ?? nsError.localizedDescription
                    return "Function error (code \(code.rawValue)): \(message)"
                }
                return "Function call failed: \(error.localizedDescription)"
            case .unknownError: return "An unknown error occurred."
            }
        }
    }
    
    private init() {}

    func callFunction<RequestData: Encodable, ResponseData: Decodable>(
        functionName: String,
        data: RequestData?,
        completion: @escaping (Result<ResponseData, ProxyServiceError>) -> Void
    ) {
        var preparedDataForFirebase: Any? = nil

        if let dataToEncode = data {
            do {
                let jsonData = try JSONEncoder().encode(dataToEncode)
                preparedDataForFirebase = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            } catch {
                completion(.failure(.encodingRequestDataFailed(error)))
                return
            }
        }

        functions.httpsCallable(functionName).call(preparedDataForFirebase) { result in
            switch result {
            case .success(let httpsCallableResult):
                guard let responseRawData = httpsCallableResult.data else {
                    if ResponseData.self == VoidDecodable.self || ResponseData.self == Optional<VoidDecodable>.self {
                        if let successValue = VoidDecodable() as? ResponseData {
                             completion(.success(successValue))
                        } else {
                            completion(.failure(.decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Expected VoidDecodable but casting failed")))))
                        }
                    } else {
                        completion(.failure(.noDataReceived))
                    }
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: responseRawData, options: [])
                    let decoder = JSONDecoder()
                    let decodedObject = try decoder.decode(ResponseData.self, from: jsonData)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(.functionError(error)))
            }
        }
    }
    // Der auskommentierte Block wurde komplett entfernt
}

// Hilfs-Structs für die callFunction (am Ende der Datei oder in einer Utils-Datei)
// private struct NoData: Encodable {} // Nicht mehr direkt hier benötigt, wenn die überladene Funktion weg ist
struct VoidDecodable: Decodable {}
