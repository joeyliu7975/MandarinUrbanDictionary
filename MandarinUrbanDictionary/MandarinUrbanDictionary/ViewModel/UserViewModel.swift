//
//  UserViewModel.swift
//  MandarinUrbanDictionary
//
//  Created by Joey Liu on 12/16/20.
//

import UIKit

class UserViewModel {
    
    typealias JoeyResult<T:Codable> = Result<T, NetworkError>
    
    private let networkManager: FirebaseManager
    private let storeManager: UserDefaults

    var challenges: [Challenge] = [.view, .like, .post]
    
    var processList: [Challenge: Process] = [:]
    
    var currentUser = Box([User]())
    
    var uid: String {
        return storeManager.string(forKey: "uid") ?? String.emptyString
    }
    
    init(networkManager: FirebaseManager = .init(), storeManger: UserDefaults = .standard) {
        self.networkManager = networkManager
        self.storeManager = storeManger
    }
    
    func fetchUserStatus() {
 
        networkManager.retrieveUser(userID: uid) { [weak self] (result: JoeyResult<User>) in
            switch result {
            case .success(let user):
                self?.currentUser.value = [user]
                
            case .failure(.decodeError):
                print("User Model decode Error!")
            case .failure(.noData(let error)):
                print(error.localizedDescription)
            }
        }
    }
    
    func startChallenge(challenge: Challenge, completion: @escaping () -> Void) {
        
        switch challenge {
        case .view:
            networkManager.updateChallenge(uid: uid, challenge: .view(0)) {
                completion()
            }
        case .like:
            networkManager.updateChallenge(uid: uid, challenge: .like(0)) {
                completion()
            }
        case .post:
            networkManager.updateChallenge(uid: uid, challenge: .post(0)) {
                completion()
            }
        }
    }
}

extension UserViewModel: ProgressBarSupportingFeatures {
    
    typealias Status = Challenge
    
    typealias Bar = ProgressBar
    
    func renewProcess(with user: User) {
        
        let postProcess = getProcess(at: .post, currentStage: user.postChallenge)
        
        let viewProcess = getProcess(at: .view, currentStage: user.viewChallenge)
        
        let favoriteProcess = getProcess(at: .like, currentStage: user.likeChallenge)
        
        processList[.post] = postProcess
        
        processList[.view] = viewProcess
        
        processList[.like] = favoriteProcess
    }
    
    func getProgressBar(_ challenge: Status) -> Bar {
        
        let progressBar = ProgressBar(title: challenge.title, color: challenge.color)
        
        return progressBar
    }
}

extension UserViewModel {
    
    enum Challenge {
        case like, view, post
        
        var title: String {
            switch self {
            case .like:
                return "按讚挑戰賽"
            case .view:
                return "幹話探索挑戰賽"
            case .post:
                return "發文挑戰賽"
            }
        }
        
        var color: UIColor {
            switch self {
            case .like:
                return .systemGreen
            case .view:
                return .systemYellow
            case .post:
                return .separatorlineBlue
            }
        }
    }
    
    enum Stage: String {
        
        case begin, process, finish
        
    }
    
    struct ProgressBar: Equatable {
        
        let title: String
        
        let color: UIColor
    }
    
    class Process {
        
        let currentStage: Int
        
        let challenge: Challenge
        
        var hasDrawed: Bool = false
        
        init(currentStage: Int, challenge: Challenge) {
            self.currentStage = currentStage
            self.challenge = challenge
        }
        
        func drawed() {
            hasDrawed = true
        }
        
        var stage: Stage {
            switch self.currentStage {
            case -1:
                return .begin
            case 0 ... 9:
                return .process
            default:
                return .finish
            }
        }
    }
    
    private func getProcess(at challenge: Challenge, currentStage: Int) -> Process {
        
        return Process(currentStage: currentStage, challenge: challenge)
        
    }
}

protocol ProgressBarSupportingFeatures {
    
    associatedtype Status
    
    associatedtype Bar
    
    func renewProcess(with user: User)
    
    func getProgressBar(_ challenge: Status) -> Bar
}

