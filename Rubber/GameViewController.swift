//
//  GameViewController.swift
//  Rubber
//
//  Created by Freddie Parks on 15/10/2017.
//  Copyright © 2017 Freddie Parks. All rights reserved.
//

import UIKit
import AVFoundation

class CodeInputButton: UIButton {
    
    private var minimumHitArea: CGSize? = CGSize(width: 40, height: 40)
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let minimumHitArea = minimumHitArea {
            
            if isHidden || !isUserInteractionEnabled || alpha == 0 {
                return nil
            }
            
            let buttonSize = bounds.size
            let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
            let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
            let largerFrame = bounds.insetBy(dx: -widthToAdd * 0.5, dy: -heightToAdd * 0.5)
            
            return largerFrame.contains(point) ? self : nil
        }
        
        return super.hitTest(point, with: event)
    }
    
}

class GameViewController: UIViewController {
    
    private var player: AVAudioPlayer?
    
    private let solutions: [String: String] = [
        "00000": "Welcome to the hunt! You can find your first set of questions at x 🏃🏻",
        "12345": "Fantastic! Chill.. You can find a new set of questions and grab a cold one at the same time 🍺",
        "11111": "Good job guys, you're doing well. Please don't ask me how to print again - copy that! 🖨",
        "22222": "Hurrah, another one in the bag. You're welcome. No, really -- welcome to Whitbread Digital, 120 Holborn ☎️",
        "78564": "Nice one! You solved the final set of questions. You've found the secret phrase:\n\n'PI Apps are the best!'\n\nGo! NOW!"
    ]
    
    private var code: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        findButtonsInSubViews(ofView: view)
    }
    
    private func findButtonsInSubViews(ofView subView: UIView) {
        
        for aSubView in subView.subviews {
            if let button = aSubView as? CodeInputButton {
                setup(button: button)
            } else {
                if aSubView.subviews.count > 0 {
                    findButtonsInSubViews(ofView: aSubView)
                }
            }
        }
    }
    
    private func setup(button: CodeInputButton) {
        
        button.addTarget(self, action: #selector(selectedCodeInputButton), for: .touchUpInside)
    }
    
    @objc private func selectedCodeInputButton(button: Any) {
        
        guard let button = button as? CodeInputButton else { return }
        guard let string = button.titleLabel?.text else { return }
        handleCodeInput(string: string)
    }
    
    private func handleCodeInput(string: String) {
        
        switch string {
        case "🔑":
            tryCode()
        case "E":
            code = ""
        default:
            code.append(string)
            playSound(named: "beep")
        }
    }
    
    private func tryCode() {
        
        if let solutionMessage = solutions[code] {
            
            code = ""
            playSound(named: "success")
            
            let alertController = UIAlertController(title: "CORRECT!", message: solutionMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {
            
            code = ""
            playSound(named: "error")
        }
    }
    
    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            player.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
}
