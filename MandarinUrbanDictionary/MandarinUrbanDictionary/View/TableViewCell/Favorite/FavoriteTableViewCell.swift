//
//  FavoriteTableViewCell.swift
//  MandarinUrbanDictionary
//
//  Created by Joey Liu on 12/1/20.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    static let identifierName = String(describing: FavoriteTableViewCell.self)

    @IBOutlet weak var cardView: CardView!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var categoryTagView: UIView!
    
    @IBOutlet weak var categoryTagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setup()
    }
    
    override func prepareForReuse() {
        self.wordLabel.text = String.emptyString
        
        self.categoryTagLabel.text = String.emptyString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.multipleSelectionBackgroundView = UIView()
    }
    
    func renderUI(word: String, tag: String) {
        
        wordLabel.text = word
        
        categoryTagLabel.text = tag
    }
    
    private func setup() {
        
        cardView.backgroundColor = .cardViewBlue

        categoryTagView.setCorner(radius: 10.0)
        
        categoryTagView.backgroundColor = .white
        
        categoryTagLabel.textColor = .cardViewBlue
    }
}
