//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by indianic on 16/11/17.
//  Copyright © 2017 indianic. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController
{
    var movesLeft = 0
    var score = 0
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var scene: GameScene!
    var level: Level!
    
    var currentLevelNum = 1
    
    lazy var backgroundMusic: AVAudioPlayer? =
        {
        guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3")
            else
        {
            return nil
        }
        do
        {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        }
        catch
        {
            return nil
        }
    }()
    
    override var prefersStatusBarHidden : Bool
    {
        return true
    }
    
    override var shouldAutorotate : Bool
    {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return[.portrait, .portraitUpsideDown]
    }
    
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//
//        //Configuring the view
//        let skView = view as! SKView
//        skView.isMultipleTouchEnabled = false
//
//        //Create and configure the scene
//        scene = GameScene(size: skView.bounds.size)
//        scene.scaleMode = .aspectFill
//
//        level = Level(filename: "Level_0")
//        scene.level = level
//        scene.addTiles()
//        scene.swipeHandler = handleSwipe
//        //Present the scene
//        skView.presentScene(scene)
//
//        backgroundMusic?.play()
//        beginGame()
//    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setup view with level 1
        setupLevel(levelNum : currentLevelNum)
        
        // Start the background music.
        backgroundMusic?.play()
    }
    
    func setupLevel(levelNum: Int)
    {
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Setup the level.
        level = Level(filename: "Level_\(levelNum)")
        scene.level = level
        
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        
//        gameOverPanel.hidden = true
//        shuffleButton.hidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        // Start the game.
        beginGame()
    }
    
    func beginGame()
    {
        shuffle()
    }
    
    func shuffle()
    {
        let newCookies = level.shuffle()
        scene.addSprites(for: newCookies)
    }
    
    func handleSwipe(_ swap : Swap)
    {
//        view.isUserInteractionEnabled = false
//
//        level.performSwap(swap: swap)
//
//        scene.animate(swap, completion : {
//            self.view.isUserInteractionEnabled = true
//        })
        
        view.isUserInteractionEnabled = false
        if level.isPossibleSwap(swap)
        {
            level.performSwap(swap: swap)
            scene.animateSwap(swap, completion: handleMatches)
        }
        else
        {
            scene.animateInvalidSwap(swap, completion : {
                self.view.isUserInteractionEnabled = true
            })
        }
    }
    
    func handleMatches()
    {
        let chains = level.removeMatches()
        if chains.count == 0
        {
            beginNextTurn()
            return
        }
        scene.animateMatchedCookies(for : chains)
        {
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns: columns)
            {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns)
                {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn()
    {
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
    }
}
