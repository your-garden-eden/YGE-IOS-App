import Foundation
import FirebaseFunctions // Stelle sicher, dass FirebaseFunctions via SPM hinzugefügt ist

class FirebaseProxyService {
    private lazy var functions = Functions.functions(region: "europe-west1") // Deine Firebase Region
    static let shared = FirebaseProxyService()

    enum ProxyServiceError: Error {
        case noDataReceived
        case decodingError(Error)
        case functionError(Error)
        case unknownError
    }
    
    private init() {} // Singleton

    func callFunction<RequestData: Encodable, ResponseData: Decodable>(
        functionName: String,
        data: RequestData?,
        completion: @escaping (Result<ResponseData, ProxyServiceError>) -> Void
    ) {
        var encodableData: Any? = nil
        if let data = data {
            do {
                // Wir müssen das Encodable in ein Dictionary oder Array umwandeln,
                // wie es Firebase Functions erwartet.
                let jsonData = try JSONEncoder().encode(data)
                encodableData = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            } catch {
                completion(.failure(.decodingError(error))) // Hier eher EncodingError, aber für Einfachheit
                return
            }
        }

        functions.httpsCallable(functionName).call(encodableData) { result in
            switch result {
            case .success(let httpsCallableResult):
                guard let responseDataObject = httpsCallableResult.data as? [String: Any] else {
                    // Manchmal geben Functions auch direkt Arrays oder primitive Typen zurück
                    // Oder wenn ResponseData ein einfacher Typ ist, der nicht in einem Dict verpackt ist.
                    // Diese Logik muss ggf. an die tatsächlichen Antworten deiner CFs angepasst werden.
                    if let directData = httpsCallableResult.data {
                        do {
                             // Versuch, direkt zu dekodieren, wenn es kein Dictionary ist
                            let jsonData = try JSONSerialization.data(withJSONObject: directData, options: [])
                            let decodedObject = try JSONDecoder().decode(ResponseData.self, from: jsonData)
                            completion(.success(decodedObject))
                        } catch {
                            completion(.failure(.decodingError(error)))
                        }
                    } else {
                         completion(.failure(.noDataReceived))
                    }
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: responseDataObject, options: [])
                    let decoder = JSONDecoder()
                    // Hier ggf. DateDecodingStrategy oder KeyDecodingStrategy setzen, falls nötig
                    // z.B. decoder.dateDecodingStrategy = .iso8601
                    let decodedObject = try decoder.decode(ResponseData.self, from: jsonData)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
                
            case .failure(let error):
                // Firebase Functions Fehler genauer prüfen
                let nsError = error as NSError
                if nsError.domain == FunctionsErrorDomain {
                    // let code = FunctionsErrorCode(rawValue: nsError.code)
                    // let message = nsError.localizedDescription
                    // let details = nsError.userInfo[FunctionsErrorDetailsKey]
                    // Hier könntest du spezifischere Fehler basierend auf code, message, details behandeln
                }
                completion(.failure(.functionError(error)))
            }
        }
    }

    // Überladene Funktion für Aufrufe ohne Request-Daten
    func callFunction<ResponseData: Decodable>(
        functionName: String,
        completion: @escaping (Result<ResponseData, ProxyServiceError>) -> Void
    ) {
        callFunction(functionName: functionName, data: Optional<Int>.none, completion: completion) // Verwende einen Dummy Encodable Typ
    }
}
