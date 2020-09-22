//
//  SphereViewController.swift
//  ThoughtCloud
//
//  Created by Jason Ono on 7/27/20.
//  Copyright © 2020 Jason Ono. All rights reserved.
//

import UIKit
import DBSphereTagCloudSwift
import NaturalLanguage

class SphereViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // root variables
    
    /// UI Elements
    
    // title
    var titleLabel = UILabel()
    // sphere
    let sphereView = DBSphereView()
    // card
    var cardView = UIView()
    // cancel button
    var cancelButton = UIButton()
    
    /// Data Elements
    
    // Imported from TypeViewConroller
    var cc = CloudCollection()
    // initial value
    var indexPathRow = 0
    // all other words will be ignored
    let relevantType: [NLTag] = [NLTag.adjective, NLTag.noun]
    var wordNum = 0
    var cwArray : [CloudWord] = []
    var cwArrayStrings: [String] = []
    var cwArrayInts: [Int] = []
    
    // help variables for autolayout
    let windowSize: CGRect = UIScreen.main.bounds
    let windowWidth: CGFloat = UIScreen.main.bounds.width
    let windowHeight: CGFloat = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9008117318, green: 0.9009597301, blue: 0.9007803798, alpha: 1)
        if let safeText = cc.text{
            let cwWArray:[CloudWord] = processText(safeText)
            cwArray = cwWArray
            cwArrayStrings = extractStrings(cwArray)
            cwArrayInts = extractInt(cwArray)
        }
        
        // UI component
        createTitleLabel()
        createSphere()
        setupUILayout()
    }
    
    // MARK: - Sphere methods
    
    func createSphere(){
        sphereView.translatesAutoresizingMaskIntoConstraints = false
        createButtons(sphereView)
        view.addSubview(sphereView)
    }
    
    func createButtons(_ sphereView: DBSphereView){
        // root variables
        var buttons:[UIButton] = []
        var sizeListDouble:[Double] = []
        let fontList:[UIFont.Weight] = [UIFont.Weight.ultraLight,
                                        UIFont.Weight.light,
                                        UIFont.Weight.thin,
                                        UIFont.Weight.regular,
                                        UIFont.Weight.bold,
                                        UIFont.Weight.heavy,
                                        UIFont.Weight.black]
        
        // planning to add more features to allow users to select the colors of their interest
        let colorList:[UIColor] = [UIColor{_ in #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)}, UIColor{_ in #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)}, UIColor{_ in #colorLiteral(red: 0.05098039216, green: 0.4509803922, blue: 0.4666666667, alpha: 1)}, UIColor{_ in #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)}]
        
        // set the font size dymically
        if cwArray.count >= 20{     // for words with 20 or more
            for i in 1..<21{
                let result = Double(i) * (35.0/20.0) + 15.0
                sizeListDouble.append(result)
            }
        }else{                      // for fewer than 20 words
            for i in 1..<cwArray.count{
                let result = Double(i) * (35.0/Double(cwArray.count)) + 15.0
                sizeListDouble.append(result)
            }
        }
        
        // because words sorted by processText are in ASCENDING order at this point
        sizeListDouble.reverse()
        
        // button initialization/add
        for i in 0..<sizeListDouble.count {
            let btn = UIButton(type: UIButton.ButtonType.system)
            btn.setTitle("\(cwArray[i].word)", for: .normal)
            btn.setTitleColor(colorList.randomElement()!, for: .normal)
            btn.setTitleShadowColor(.lightGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(sizeListDouble[i]), weight: fontList.randomElement()!)
            btn.frame = CGRect(x: 0, y: 0, width: 290, height: 20)
            btn.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
            buttons.append(btn)
            sphereView.addSubview(btn)
        }
        sphereView.setCloudTags(buttons)
    }
    
    @objc func buttonPressed(btn: UIButton) {
        createCard()
        createLabel(btn.currentTitle!)
        sphereView.timerStop()
        UIView.animate(withDuration: 0.3, animations: {
            btn.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                btn.transform = CGAffineTransform(scaleX: 1, y: 1);
            }, completion: { _ in
                self.sphereView.timerStart()
            })
        })
    }
    
    func createTitleLabel(){
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.text = cc.title
        titleLabel.addInterlineSpacing(spacingValue: 0.5)
        titleLabel.textColor = #colorLiteral(red: 0.4479508996, green: 0.4480288029, blue: 0.4479343295, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .black)
    }
    
    // MARK: - Card methods
    func createCard(){
        if view.subviews.contains(cardView){
            self.cardView.removeFromSuperview()
        }
        cardView.layer.cornerRadius = 10
        cardView.backgroundColor = .white
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        createButton()
        cardView.alpha = 0
        label.alpha = 0
        cancelButton.alpha = 0
        layoutCard()
        UIView.animate(withDuration: 0.5) {self.cardView.alpha = 1; self.label.alpha = 1; self.cancelButton.alpha = 1}
    }
    
    func createButton(){
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .large)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        cancelButton.tintColor = .systemGray
        //        shutterButton.backgroundColor = .red
        cancelButton.addTarget(self, action: #selector(wasTapped), for: .touchUpInside)
        cancelButton.setImage(image, for: .normal)
        //        shutterButton.frame = CGRect(x: 200, y: 200, width: 200, height: 200)
    }
    
    func layoutCard(){
        [cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: windowHeight*0.53),
         cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: windowWidth*0.07),
         cardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -windowWidth*0.07),
         cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -windowWidth*0.07),
            ].forEach{ $0.isActive = true }
        [cancelButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: windowWidth*0.03),
         cancelButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: windowWidth*0.03),
            ].forEach{ $0.isActive = true }
    }
    
    
    @objc func wasTapped() {
        UIView.animate(withDuration: 0.5, animations: {self.cardView.alpha = 0.0; self.label.alpha = 0.0; self.cancelButton.alpha = 0.0},
                       completion: {(value: Bool) in
                        self.label.removeFromSuperview()
                        self.cardView.removeFromSuperview()
                        self.cancelButton.removeFromSuperview()
        })
    }
    
    var label = UILabel()
    func createLabel(_ title: String){
        view.addSubview(label)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = label.font.withSize(27)
        label.allowsDefaultTighteningForTruncation = true
        //        label.lineBreakMode = .byClipping
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        let word = title.capitalized
        let indexNum = cwArrayStrings.firstIndex(of: title)
        let numOfTimes = cwArrayInts[indexNum!]
        if (indexNum==0){
            label.text = "\(word) is the most frequently used word, which shows up \(numOfTimes) times in the given text."
        }else if(indexNum==1){
            label.text = "\(word) is the 2nd most frequently used word, which shows up \(numOfTimes) times in the given text."
        }else if(indexNum==2){
            label.text = "\(word) is the 3rd most frequently used word, which shows up \(numOfTimes) times in the given text."
        }else{
            let resInt = indexNum! as Int
            let resStr = String(resInt)
            label.text = "\(word) is the \(resStr)th most used word, which shows up \(numOfTimes) times in the given text."
        }
        [label.topAnchor.constraint(equalTo: cardView.topAnchor, constant: windowWidth*0.06),
         label.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: windowWidth*0.06),
         label.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -windowWidth*0.06),
         label.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -windowWidth*0.06),
            ].forEach{ $0.isActive = true }
    }
    
    // MARK: - Text Process methods
    
    func extractStrings(_ cwArr: [CloudWord])->[String]{
        var arrStr : [String] = []
        for i in 0..<(cwArr.count){
            arrStr.append(cwArr[i].word)
        }
        return arrStr
    }
    
    func extractInt(_ cwArr: [CloudWord])->[Int]{
        var arrInt : [Int] = []
        for i in 0..<(cwArr.count){
            arrInt.append(cwArr[i].numOfTimes)
        }
        return arrInt
    }
    
    func setVariableSets(){
        // number of words to display
        if cwArray.count >= 20{
            wordNum = 20
        } else{
            wordNum = cwArray.count
        }
    }
    
    func processText(_ text: String)->[CloudWord]{
        // initiate an empty CloudWord array
        var cloudWordArray: [CloudWord] = []
        
        // prep for NL process
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        // ignore punctuation and white space
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                // checker Int and individual word
                var checker: Int = 0
                let theTag: String = String(text[tokenRange])
                
                // duplicate check
                for i in 0..<(cloudWordArray.count){
                    if cloudWordArray[i].word == theTag{
                        cloudWordArray[i].increNumOfTimes()
                        checker+=1
                    }
                }
                
                // create and add to the array only when the word is new and the type is relevant
                if (checker==0 && relevantType.contains(NLTag(rawValue: tag.rawValue)) == true){
                    let newCloudWord = CloudWord(theTag, NLTag(rawValue: tag.rawValue))
                    cloudWordArray.append(newCloudWord)
                }
            }
            return true
        }
        cloudWordArray.sort()
        cloudWordArray.reverse()
        return cloudWordArray
    }
    
    
    // MARK: - AutoLayout
    func setupUILayout(){
        [titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: windowWidth*0.01),
         titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: windowWidth*0.05),
         titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor)
            ].forEach{ $0.isActive = true }
        
        [sphereView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: windowWidth*0.08),
         sphereView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         sphereView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: windowWidth*0.15),
         sphereView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: windowWidth*0.4),
         sphereView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -windowWidth*0.15),
            ].forEach{ $0.isActive = true }
        
        
    }
    
    // MARK: - Data Retrieval from TypeViewController
    func passCC(_ inputCloudCollection: CloudCollection, _ indexPath: Int){     // called in TVC
        cc = inputCloudCollection
        indexPathRow = indexPath
    }
    
    // MARK: - Navigation Controller Methods
    
    // Make the navigation bar background clear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // Restore the navigation bar to default
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
}

// MARK: - UILabel

extension UILabel {

    func addInterlineSpacing(spacingValue: CGFloat = 2) {
        guard let textString = text else { return }
        let attributedString = NSMutableAttributedString(string: textString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacingValue
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length
        ))
        attributedText = attributedString
    }
    
}

// MARK: - UIView
extension UIView {
    public var viewWidth: CGFloat {
        return self.frame.size.width
    }
    
    public var viewHeight: CGFloat {
        return self.frame.size.height
    }
}
