//
//  DefaultsManager.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 09.12.2020.
//

import Foundation

enum DefaultsStorageKey: String {
    case moviesModel
    case searchMovieModel
    case movieDetail
}

final class DefaultsManager {
    
    private static let defaults = UserDefaults.standard
    
    // MARK: - Codable objects
    
    private class func getKey(from key: DefaultsStorageKey, id: String?) -> String {
        id != nil ? "\(key.rawValue)#\(id!)" : key.rawValue
    }
    
    class func hasEntity(by key: DefaultsStorageKey, id: String?) -> Bool {
        let key = getKey(from: key, id: id)
        return (defaults.value(forKey: key) as? Data) != nil
    }
    
    class func set<T: Codable>(entity: T, by key: DefaultsStorageKey, id: String?) {
        let key = getKey(from: key, id: id)
        if let encoded = try? JSONEncoder().encode(entity) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    class func getEntity<T: Codable>(by key: DefaultsStorageKey, id: String?) -> T? {
        let key = getKey(from: key, id: id)
        guard let data = defaults.value(forKey: key) as? Data else { return nil }
        let entity = try? JSONDecoder().decode(T.self, from: data)
        return entity
    }
    
    // MARK: - String
    
    class func set(string: String, by key: DefaultsStorageKey, id: String?) {
        let key = getKey(from: key, id: id)
        defaults.set(string, forKey: key)
    }

    class func getString(by key: DefaultsStorageKey, id: String?) -> String? {
        let key = getKey(from: key, id: id)
        guard let string = defaults.string(forKey: key) else { return nil }
        return string
    }
    
    // MARK: - Data
    
    class func setData(_ data: Data, by key: DefaultsStorageKey, id: String?) {
        let key = getKey(from: key, id: id)
        defaults.set(data, forKey: key)
    }
    
    class func getData(by key: DefaultsStorageKey, id: String?) -> Data? {
        let key = getKey(from: key, id: id)
        return defaults.value(forKey: key) as? Data
    }
    
    // MARK: - Delete
    
    class func delete(by key: DefaultsStorageKey, id: String?) {
        let key = getKey(from: key, id: id)
        defaults.removeObject(forKey: key)
    }
}
