import Foundation
import AsyncDisplayKit
import Display
import TelegramCore
import Postbox
import SwiftSignalKit

final class DeleteChatInputPanelNode: ChatInputPanelNode {
    private let button: HighlightableButtonNode
    
    private var presentationInterfaceState = ChatPresentationInterfaceState()
    
    override init() {
        self.button = HighlightableButtonNode()
        self.button.isUserInteractionEnabled = false
        
        super.init()
        
        self.addSubnode(self.button)
        
        self.button.addTarget(self, action: #selector(self.buttonPressed), forControlEvents: [.touchUpInside])
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.bounds.contains(point) {
            return self.button.view
        } else {
            return nil
        }
    }
    
    @objc func buttonPressed() {
        self.interfaceInteraction?.deleteChat()
    }
    
    override func updateLayout(width: CGFloat, transition: ContainedViewLayoutTransition, interfaceState: ChatPresentationInterfaceState) -> CGFloat {
        if self.presentationInterfaceState != interfaceState {
            self.presentationInterfaceState = interfaceState
            
            self.button.setAttributedTitle(NSAttributedString(string: "Delete and Exit", font: Font.regular(17.0), textColor: UIColor(0xff3b30)), for: [])
        }
        
        let buttonSize = self.button.measure(CGSize(width: width - 10.0, height: 100.0))
        
        let panelHeight: CGFloat = 47.0
        
        self.button.frame = CGRect(origin: CGPoint(x: floor((width - buttonSize.width) / 2.0), y: floor((panelHeight - buttonSize.height) / 2.0)), size: buttonSize)
        
        return panelHeight
    }
}
