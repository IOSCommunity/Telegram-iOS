import Foundation
import AsyncDisplayKit
import Display
import TelegramCore
import Postbox
import SwiftSignalKit

final class ChatUnblockInputPanelNode: ChatInputPanelNode {
    private let button: HighlightableButtonNode
    private let activityIndicator: UIActivityIndicatorView
    
    private var statusDisposable: Disposable?
    
    private var presentationInterfaceState = ChatPresentationInterfaceState()
    
    override var interfaceInteraction: ChatPanelInterfaceInteraction? {
        didSet {
            if self.statusDisposable == nil {
                if let startingBot = self.interfaceInteraction?.statuses?.unblockingPeer {
                    self.statusDisposable = (startingBot |> deliverOnMainQueue).start(next: { [weak self] value in
                        if let strongSelf = self {
                            if value != !strongSelf.activityIndicator.isHidden {
                                if value {
                                    strongSelf.activityIndicator.isHidden = false
                                    strongSelf.activityIndicator.startAnimating()
                                } else {
                                    strongSelf.activityIndicator.isHidden = true
                                    strongSelf.activityIndicator.stopAnimating()
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    override init() {
        self.button = HighlightableButtonNode()
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator.isHidden = true
        
        super.init()
        
        self.addSubnode(self.button)
        self.view.addSubview(self.activityIndicator)
        
        self.button.setAttributedTitle(NSAttributedString(string: "Unblock", font: Font.regular(17.0), textColor: UIColor(0x007ee5)), for: [])
        self.button.addTarget(self, action: #selector(self.buttonPressed), forControlEvents: [.touchUpInside])
    }
    
    deinit {
        self.statusDisposable?.dispose()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.bounds.contains(point) {
            return self.button.view
        } else {
            return nil
        }
    }
    
    @objc func buttonPressed() {
        self.interfaceInteraction?.unblockPeer()
    }
    
    override func updateLayout(width: CGFloat, transition: ContainedViewLayoutTransition, interfaceState: ChatPresentationInterfaceState) -> CGFloat {
        if self.presentationInterfaceState != interfaceState {
            self.presentationInterfaceState = interfaceState
        }
        
        let buttonSize = self.button.measure(CGSize(width: width - 80.0, height: 100.0))
        
        let panelHeight: CGFloat = 47.0
        
        self.button.frame = CGRect(origin: CGPoint(x: floor((width - buttonSize.width) / 2.0), y: floor((panelHeight - buttonSize.height) / 2.0)), size: buttonSize)
        
        let indicatorSize = self.activityIndicator.bounds.size
        self.activityIndicator.frame = CGRect(origin: CGPoint(x: width - indicatorSize.width - 12.0, y: floor((panelHeight - indicatorSize.height) / 2.0)), size: indicatorSize)
        
        return 47.0
    }
}
