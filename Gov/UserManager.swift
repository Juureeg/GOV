//
//  UserManager.swift
//  Gov
//
//  Manages user authentication and image loading from hosted JSON
//

import SwiftUI

// MARK: - User Data Models
struct UserData: Codable {
    let password: String
    let name: String
    let images: UserImages
}

struct UserImages: Codable {
    let idCard2: String
    let idCard3: String
    let idCard4: String
    let idCard5: String
    let profile: String
}

struct UsersDatabase: Codable {
    let users: [String: UserData]
}

// MARK: - User Manager (Singleton)
class UserManager: ObservableObject {
    static let shared = UserManager()
    
    // IMPORTANT: Replace this URL with your hosted JSON URL
    private let databaseURL = "https://raw.githubusercontent.com/Juureeg/GOV/main/users.json"
    
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentUsername: String?
    @Published var currentUserName: String?
    
    // Cached images
    @Published var profileImage: UIImage?
    @Published var idCardImages: [UIImage] = []
    
    private var usersDatabase: UsersDatabase?
    
    private init() {
        // Check if user was previously logged in
        if let savedUsername = UserDefaults.standard.string(forKey: "loggedInUser") {
            // Auto-login
            autoLogin(username: savedUsername)
        }
    }
    
    // MARK: - Fetch Users Database
    private func fetchDatabase(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: databaseURL) else {
            errorMessage = "URL inválida"
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Erro de conexão: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Dados não recebidos"
                    completion(false)
                    return
                }
                
                do {
                    let database = try JSONDecoder().decode(UsersDatabase.self, from: data)
                    self?.usersDatabase = database
                    completion(true)
                } catch {
                    self?.errorMessage = "Erro ao processar dados: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Login
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        fetchDatabase { [weak self] success in
            guard let self = self else { return }
            
            if !success {
                self.isLoading = false
                completion(false)
                return
            }
            
            // Check credentials
            let lowercaseUsername = username.lowercased()
            guard let user = self.usersDatabase?.users[lowercaseUsername] else {
                self.errorMessage = "Usuário não encontrado"
                self.isLoading = false
                completion(false)
                return
            }
            
            if password == user.password {
                // Login successful
                self.currentUsername = lowercaseUsername
                self.currentUserName = user.name
                UserDefaults.standard.set(lowercaseUsername, forKey: "loggedInUser")
                
                // Load images
                self.loadUserImages(user: user) {
                    self.isLoggedIn = true
                    self.isLoading = false
                    completion(true)
                }
            } else {
                self.errorMessage = "Senha incorreta"
                self.isLoading = false
                completion(false)
            }
        }
    }
    
    // MARK: - Auto Login
    private func autoLogin(username: String) {
        isLoading = true
        
        fetchDatabase { [weak self] success in
            guard let self = self, success,
                  let user = self.usersDatabase?.users[username] else {
                self?.isLoading = false
                self?.logout()
                return
            }
            
            self.currentUsername = username
            self.currentUserName = user.name
            
            self.loadUserImages(user: user) {
                self.isLoggedIn = true
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Load User Images
    private func loadUserImages(user: UserData, completion: @escaping () -> Void) {
        let imageURLs = [
            user.images.idCard2,
            user.images.idCard3,
            user.images.idCard4,
            user.images.idCard5
        ]
        
        var loadedImages: [UIImage?] = [nil, nil, nil, nil]
        let group = DispatchGroup()
        
        // Load ID card images
        for (index, urlString) in imageURLs.enumerated() {
            group.enter()
            loadImage(from: urlString) { image in
                loadedImages[index] = image
                group.leave()
            }
        }
        
        // Load profile image
        group.enter()
        loadImage(from: user.images.profile) { [weak self] image in
            DispatchQueue.main.async {
                self?.profileImage = image
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.idCardImages = loadedImages.compactMap { $0 }
            completion()
        }
    }
    
    // MARK: - Load Single Image
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
    
    // MARK: - Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "loggedInUser")
        currentUsername = nil
        currentUserName = nil
        profileImage = nil
        idCardImages = []
        isLoggedIn = false
        usersDatabase = nil
    }
}
