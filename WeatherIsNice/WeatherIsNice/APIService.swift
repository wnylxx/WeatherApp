//
//  APIService.swift
//  TestWeatherApp
//
//  Created by wonyoul heo on 5/1/24.
//

import Foundation

public class ForecastAPIService {
    public static let shared = ForecastAPIService()
    
    public enum APIError: Error {
        case error(_ errorString: String)
    }
    
    
    func getJSON(urlString: String,
                 dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                 keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                 completion: @escaping (Result<Forecast, APIError>) -> Void) {  // Result<성공, 실패>
        guard let url = URL(string: urlString) else {
            completion(.failure(.error("Error: Invalid URL")))
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.error("Error: \(error.localizedDescription)")))
                return
            }
            
            guard let data = data else {
                completion(.failure(.error(NSLocalizedString("Error: Data us corrupt.", comment: ""))))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy  // 날짜 디코딩 방법
            decoder.keyDecodingStrategy = keyDecodingStrategy   // ket 디코딩 방법
            
            do {
                let decodedData = try decoder.decode(Forecast.self, from: data) // JSON 데이터를 디코딩 하여 Forecast 모델로 변환
                completion(.success(decodedData))                               // 디코딩된 데이터를 completion zmffhwjdml .success 케이스로 전달하여 완료됨을 알림
            } catch let decodingError {                                         // 실패 시
                completion(.failure(APIError.error("Error: \(decodingError.localizedDescription)")))
                return
            }
            
        }.resume()
    }
}

public class CurrentAPIService {
    public static let shared = CurrentAPIService()

    public enum APIError: Error {
        case error(_ errorString: String)
    }


    func getJSON(urlString: String,
                 dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                 keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                 completion: @escaping (Result<Current, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.error("Error: Invalid URL")))
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.error("Error: \(error.localizedDescription)")))
                return
            }

            guard let data = data else {
                completion(.failure(.error(NSLocalizedString("Error: Data us corrupt.", comment: ""))))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy

            do {
                let decodedData = try decoder.decode(Current.self, from: data)
                completion(.success(decodedData))
            } catch let decodingError {
                completion(.failure(APIError.error("Error: \(decodingError.localizedDescription)")))
                return
            }

        }.resume()
    }
}
