//
//  ALKMyMessageView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 08/01/19.
//

/// A custom view which has text, time and state labels. And it's used in multiple cells.
class ALKMyMessageView: UIView {

    struct Padding {
        struct MessageView {
            static let top: CGFloat = 4
            static let bottom: CGFloat = 6
        }
        struct BubbleView {
            static let bottom: CGFloat = 2
        }
        struct StateView {
            static let bottom: CGFloat = 1
            static let right: CGFloat = 2
        }
        struct TimeLabel {
            static let right: CGFloat = 2
            static let bottom: CGFloat = 2
        }
    }

    fileprivate var widthPadding: CGFloat = CGFloat(ALKMessageStyle.sentBubble.widthPadding)
    fileprivate lazy var messageView: ALKHyperLabel = {
        let label = ALKHyperLabel.init(frame: .zero)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    fileprivate var bubbleView: UIImageView = {
        let bv = UIImageView()
        let image = UIImage.init(named: "chat_bubble_rounded", in: Bundle.applozic, compatibleWith: nil)
        bv.tintColor = UIColor(netHex: 0xF1F0F0)
        bv.image = image?.imageFlippedForRightToLeftLayoutDirection()
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
    }()

    init() {
        super.init(frame: .zero)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: ALKMessageViewModel) {
        // Set message
        messageView.text = viewModel.message ?? ""
        messageView.setStyle(ALKMessageStyle.message)

        // Set time
        timeLabel.text = viewModel.time
        timeLabel.setStyle(ALKMessageStyle.time)

        // Set read status
        if viewModel.isAllRead {
            stateView.image = UIImage(named: "read_state_3", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor(netHex: 0x0578FF)
        } else if viewModel.isAllReceived {
            stateView.image = UIImage(named: "read_state_2", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else if viewModel.isSent {
            stateView.image = UIImage(named: "read_state_1", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else {
            stateView.image = UIImage(named: "seen_state_0", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor.red
        }
    }

    class func rowHeight(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let minimumHeight: CGFloat = 10 // Padding
        guard let message = viewModel.message else {
            return minimumHeight
        }
        let font = ALKMessageStyle.message.font
        var messageHeight = message.heightWithConstrainedWidth(width: width, font: font)
        messageHeight += 20 // (6 + 4) + 10 for extra padding
        return max(messageHeight, minimumHeight)
    }
    
    private func setupConstraints() {
        self.addViewsForAutolayout(views: [messageView, bubbleView, stateView, timeLabel])
        self.bringSubview(toFront: messageView)
        messageView.topAnchor.constraint(equalTo: self.topAnchor, constant: Padding.MessageView.top).isActive = true
        messageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * Padding.MessageView.bottom).isActive = true
        messageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor).isActive = true

        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -widthPadding).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: widthPadding).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * Padding.BubbleView.bottom).isActive = true

        stateView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: 9.0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1 * Padding.StateView.bottom).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -1 * Padding.StateView.right).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * Padding.TimeLabel.right).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: Padding.TimeLabel.bottom).isActive = true
    }

}
