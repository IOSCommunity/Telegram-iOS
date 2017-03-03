import Foundation
import AsyncDisplayKit
import TelegramCore

func inputPanelForChatPresentationIntefaceState(_ chatPresentationInterfaceState: ChatPresentationInterfaceState, account: Account, currentPanel: ChatInputPanelNode?, textInputPanelNode: ChatTextInputPanelNode?, interfaceInteraction: ChatPanelInterfaceInteraction?) -> ChatInputPanelNode? {
    if let selectionState = chatPresentationInterfaceState.interfaceState.selectionState {
        if let currentPanel = currentPanel as? ChatMessageSelectionInputPanelNode {
            currentPanel.selectedMessageCount = selectionState.selectedIds.count
            currentPanel.interfaceInteraction = interfaceInteraction
            return currentPanel
        } else {
            let panel = ChatMessageSelectionInputPanelNode()
            panel.account = account
            panel.selectedMessageCount = selectionState.selectedIds.count
            panel.interfaceInteraction = interfaceInteraction
            return panel
        }
    } else {
        if chatPresentationInterfaceState.peerIsBlocked {
            if let currentPanel = currentPanel as? ChatUnblockInputPanelNode {
                currentPanel.interfaceInteraction = interfaceInteraction
                return currentPanel
            } else {
                let panel = ChatUnblockInputPanelNode()
                panel.account = account
                panel.interfaceInteraction = interfaceInteraction
                return panel
            }
        }
        
        if let peer = chatPresentationInterfaceState.peer {
            if let secretChat = peer as? TelegramSecretChat {
                switch secretChat.embeddedState {
                    case .handshake:
                        if let currentPanel = currentPanel as? SecretChatHandshakeStatusInputPanelNode {
                            return currentPanel
                        } else {
                            let panel = SecretChatHandshakeStatusInputPanelNode()
                            panel.account = account
                            panel.interfaceInteraction = interfaceInteraction
                            return panel
                        }
                    case .terminated:
                        if let currentPanel = currentPanel as? DeleteChatInputPanelNode {
                            return currentPanel
                        } else {
                            let panel = DeleteChatInputPanelNode()
                            panel.account = account
                            panel.interfaceInteraction = interfaceInteraction
                            return panel
                        }
                    case .active:
                        break
                }
            } else if let channel = peer as? TelegramChannel {
                switch channel.participationStatus {
                    case .kicked, .left:
                        if let currentPanel = currentPanel as? DeleteChatInputPanelNode {
                            return currentPanel
                        } else {
                            let panel = DeleteChatInputPanelNode()
                            panel.account = account
                            panel.interfaceInteraction = interfaceInteraction
                            return panel
                        }
                    case .member:
                        break
                }
                switch channel.info {
                    case .broadcast:
                        switch channel.role {
                            case .creator, .editor, .moderator:
                                break
                            case .member:
                                if let currentPanel = currentPanel as? ChatChannelSubscriberInputPanelNode {
                                    return currentPanel
                                } else {
                                    let panel = ChatChannelSubscriberInputPanelNode()
                                    panel.account = account
                                    return panel
                                }
                        }
                    case .group:
                        switch channel.participationStatus {
                            case .kicked, .left:
                                if let currentPanel = currentPanel as? ChatChannelSubscriberInputPanelNode {
                                    return currentPanel
                                } else {
                                    let panel = ChatChannelSubscriberInputPanelNode()
                                    panel.account = account
                                    return panel
                                }
                            case .member:
                                break
                        }
                }
            } else if let group = peer as? TelegramGroup {
                switch group.membership {
                    case .Removed, .Left:
                        if let currentPanel = currentPanel as? DeleteChatInputPanelNode {
                            return currentPanel
                        } else {
                            let panel = DeleteChatInputPanelNode()
                            panel.account = account
                            panel.interfaceInteraction = interfaceInteraction
                            return panel
                        }
                    case .Member:
                        break
                }
            }
            
            var displayBotStartPanel = false
            if let _ = chatPresentationInterfaceState.botStartPayload {
                displayBotStartPanel = true
            } else if let chatHistoryState = chatPresentationInterfaceState.chatHistoryState, case .loaded(true) = chatHistoryState {
                if let user = chatPresentationInterfaceState.peer as? TelegramUser, user.botInfo != nil {
                    displayBotStartPanel = true
                }
            }
            
            if displayBotStartPanel {
                if let currentPanel = currentPanel as? ChatBotStartInputPanelNode {
                    return currentPanel
                } else {
                    let panel = ChatBotStartInputPanelNode()
                    panel.account = account
                    panel.interfaceInteraction = interfaceInteraction
                    return panel
                }
            } else {
                if let currentPanel = currentPanel as? ChatTextInputPanelNode {
                    currentPanel.interfaceInteraction = interfaceInteraction
                    return currentPanel
                } else {
                    if let textInputPanelNode = textInputPanelNode {
                        textInputPanelNode.interfaceInteraction = interfaceInteraction
                        textInputPanelNode.account = account
                        return textInputPanelNode
                    } else {
                        let panel = ChatTextInputPanelNode()
                        panel.interfaceInteraction = interfaceInteraction
                        panel.account = account
                        return panel
                    }
                }
            }
        } else {
            return nil
        }
    }
}
