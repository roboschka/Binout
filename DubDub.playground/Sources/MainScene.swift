import UIKit
import SpriteKit
import GameplayKit
import SceneKit

public class MainScene : SKScene {
    let BallCategoryName = "ball"
    let PaddleCategoryName = "paddle"
    let BlockCategoryName = "block"
    let GameMessageName = "gameMessage"

    let BallCategory   : UInt32 = 0x1 << 1
    let BottomCategory : UInt32 = 0x1 << 2
    let BlockCategory  : UInt32 = 0x1 << 3
    let PaddleCategory : UInt32 = 0x1 << 4
    let BorderCategory : UInt32 = 0x1 << 5
    
    
}
