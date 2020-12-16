//
//  FavoriteViewModel.swift
//  MandarinUrbanDictionary
//
//  Created by Joey Liu on 12/9/20.
//

import Foundation

class FavoriteViewModel {
    
    var title: String
    
    var user: User? {
        
        didSet {
            guard let user = user else { return }
            
            switch title == "我的最愛" {
            case true:
                
                user.favorites.forEach {
                    
                    networkManager.retrieveWord(id: $0) { (result: Result<Word, NetworkError>) in
                        switch result {
                        case .success(let word):
                            self.favoriteViewModels.value.append(word)
                        case .failure(.noData(let error)):
                            print(error.localizedDescription)
                        case .failure(.decodeError):
                            print("Decode Error!")
                        }
                    }
                }
                
            case false:
                
                user.recents.forEach {
                    networkManager.retrieveWord(id: $0) { (result: Result<Word, NetworkError>) in
                        switch result {
                        case .success(let word):
                            self.favoriteViewModels.value.append(word)
                        case .failure(.noData(let error)):
                            print(error.localizedDescription)
                        case .failure(.decodeError):
                            print("Decode Error!")
                        }
                    }
                }
            }
        }
    }
    
    let networkManager: FirebaseManager = .init()
    
    var favoriteViewModels = Box([Word]())
    
    var selectedWord = [Word]() {
        didSet {
            
            deleteButtonEnable?(!selectedWord.isEmpty)
            
        }
    }
    
    var isEditing: Bool = false {
        didSet {
            toggleEditMode?(isEditing)
        }
    }
    
    var fetchData: (() -> Void)?
    
    var toggleEditMode: ((Bool) -> Void)?
    
    var removeData: (([Int]) -> Void)?
    
    var deleteButtonEnable: ((Bool) -> Void)?
    
    init(title: String) {
        self.title = title
    }
    
    // Firebase 操作
    
    func getUserFavoriteWordsList() {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
 
        networkManager.retrieveUser(userID: uid) { (result: Result<User, NetworkError>) in
            switch result {
            case .success(let user):
                
                self.user = user
                
            case .failure(.noData(let error)):
                print(error.localizedDescription)
            case .failure(.decodeError):
                print("Decode Error!")
            }
        }
    }
    
    func removeArray(words: [Word], completion: () -> Void) {
        
        var fieldName: String
        
        if let user = user {
            
            switch title == "我的最愛" {
            case true:
                fieldName = "favorite_words"
            case false:
                fieldName = "recent_search"
            }
        
            words.forEach {
                
                networkManager.deleteArray(uid: user.identifier, wordID: $0.identifier, arrayName: fieldName)

            }
            
            completion()
        }
        
    }
    
    // MARK Local 操作
    
    func select(at index: IndexPath) {
        
       let isWordSelected = selectedWord.contains(favoriteViewModels.value[index.row])
        
        switch isWordSelected {
        case true:
           
            guard let index = selectedWord.firstIndex(of: favoriteViewModels.value[index.row]) else { return }
            
            selectedWord.remove(at: index)
            
        case false:
            
            selectedWord.append(favoriteViewModels.value[index.row])
            
        }
    }
    
    func tapDelete() {
        
        var favoritedWords = [Int]()
        
        selectedWord.map {
            if let index = favoriteViewModels.value.firstIndex(of: $0) {
                favoritedWords.append(index)
            }
        }
            
        removeArray(words: selectedWord) {
            
            self.removeData?(Array(favoritedWords))
            
        }
        
        selectedWord.removeAll()
    }
    
    func tapDeleteAll() {
        
        removeArray(words: favoriteViewModels.value) {
            isEditing = false
            favoriteViewModels.value.removeAll()
        }
    }
    
    func removeSelections() {

            selectedWord.removeAll()

    }
    
}
