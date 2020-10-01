//
//  NeuButtonContent.swift
//  NeumorphicKit
//
//  Created by Prashant Shrivastava on 12/06/20.
//  Copyright © 2020 CRED. All rights reserved.
//

import UIKit

class NeuButtonContent: UIView {
    
    private var contentView: UIView!
    private var contentStackView: UIStackView!
    private var circleContainerView: UIView!
    private var circleView: UIView!
    private var imageView: UIImageView!
    private var titleView: UIView!
    private var titleLabel: UILabel!
    private var imageDimensionConstraint: NSLayoutConstraint!
    
    private var circleBlurAmount: CGFloat!
    private var stackContentPadding: CGFloat!
    private var contentModel: NeuConstants.NeuButtonContentModel!

    private let defaultImageDimension: CGFloat = 20

    /// Used to update content view when state changes
    var state: NeuConstants.NeuButtonState = .normal {
        didSet {
            if state == .pressed && oldValue != state {
                generateHaptic(style: .medium)
            }
            updateContentView()
        }
    }
    
    // MARK: Initializers

    init(frame: CGRect, contentModel: NeuConstants.NeuButtonContentModel) {
        self.contentModel = contentModel
        self.circleBlurAmount = contentModel.circleBlurAmount
        self.stackContentPadding = contentModel.stackContentPadding
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: Public

    /// Used to update view contents when bounds changes
    func resizeContentView(to bounds: CGRect) {
        frame = bounds
        contentView.frame = self.bounds
        contentStackView.frame = self.bounds.insetBy(dx: stackContentPadding, dy: stackContentPadding)
        updateContentView()
    }

    /// Sets image and title configurations
    /// - Parameters:
    ///   - title: sets attributed title to titleLabel, hides if no title present
    ///   - image: sets image to imageView, hides if no image present
    ///   - imageTintColor: sets image tint color
    ///   - imageDimension: changes image dimension
    func setAttributedTitle(title: NSAttributedString?, with image: UIImage?, imageTintColor: UIColor, imageDimension: CGFloat) {
        imageDimensionConstraint.constant = imageDimension
        updateTitleAndImage(title: title, image: image, imageTintColor: imageTintColor)
    }
    
    // MARK: Private

    private func updateTitleAndImage(title: NSAttributedString?, image: UIImage?, imageTintColor: UIColor) {
        titleLabel.isHidden = title == nil || title?.string.isEmpty == true
        if !titleLabel.isHidden {
            titleLabel.attributedText = title
            titleLabel.textAlignment = .center
        }
        if let imageT = image {
            circleContainerView.isHidden = false
            imageView.image = imageT
            imageView.tintColor = imageTintColor
        } else {
            circleContainerView.isHidden = true
        }
    }
    
    private func setupViews() {
        
        layer.cornerRadius = bounds.height/2
        
        contentView = UIView(frame: bounds)
        addSubview(contentView)
        
        contentStackView = UIStackView(frame: bounds.insetBy(dx: stackContentPadding, dy: stackContentPadding))
        addSubview(contentStackView)
        
        contentStackView.axis = .horizontal
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 0
        
        setupCircleView()
        contentStackView.addArrangedSubview(circleContainerView)
        
        setupTitleView()
        contentStackView.addArrangedSubview(titleView)
        
        layoutIfNeeded()
        updateContentView()
    }
    
    private func setupCircleView() {
        
        circleContainerView = UIView()
        circleContainerView.translatesAutoresizingMaskIntoConstraints = false
        circleContainerView.widthAnchor.constraint(equalTo: circleContainerView.heightAnchor, multiplier: 1.0).isActive = true
        
        circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleContainerView.addSubview(circleView)
        
        circleView.leadingAnchor.constraint(equalTo: circleContainerView.leadingAnchor).isActive = true
        circleView.trailingAnchor.constraint(equalTo: circleContainerView.trailingAnchor).isActive = true
        circleView.topAnchor.constraint(equalTo: circleContainerView.topAnchor).isActive = true
        circleView.bottomAnchor.constraint(equalTo: circleContainerView.bottomAnchor).isActive = true
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        circleContainerView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: circleContainerView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: circleContainerView.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true

        imageDimensionConstraint = imageView.widthAnchor.constraint(equalToConstant: defaultImageDimension)
        imageDimensionConstraint.isActive = true
    }

    private func setupTitleView() {
        
        titleView = UIView()

        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(titleLabel)
        
        titleView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0).isActive = true
        titleView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0).isActive = true
        titleView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 1).isActive = true
    }
    
    private func updateContentView() {
        
        NeuUIHelper.removeAllSublayers(view: contentView)
        contentView.layer.cornerRadius = contentView.bounds.height/2
        circleView.layer.cornerRadius = circleView.bounds.height/2
        
        updateTitleState()
        updateImageViewState()
        updateContentLayers()
        updateCircleView()
    }

    private func updateTitleState() {

        switch state {
        case .normal:
            titleLabel.alpha = 0.9
        case .pressed:
            titleLabel.alpha = 0.5
        case .disabled:
            titleLabel.alpha = 0.3
        }
    }

    private func updateImageViewState() {

        switch state {
        case .normal:
            imageView.alpha = 0.8
        case .pressed:
            imageView.alpha = 0.3
        case .disabled:
            imageView.alpha = 0.3
        }
    }

    private func updateContentLayers() {
        addContentShadow()
        addContentGradient()
        addContentBorder()
        addContentInnerShadow()
    }
    
    private func updateCircleView() {

        guard let colors = state == .normal ? contentModel.normalCircleGradientColors : contentModel.highlightedCircleGradientColors else { return }

        let (startPoint, endPoint) = NeuUIHelper.getGradientDirection(lightDirection: contentModel.lightDirection)
        let circleGradientLayer = CAGradientLayer()
        circleGradientLayer.masksToBounds = true
        circleGradientLayer.colors = colors
        circleGradientLayer.startPoint = startPoint
        circleGradientLayer.endPoint = endPoint
        circleGradientLayer.frame = circleView.bounds
        circleGradientLayer.cornerRadius = circleView.layer.cornerRadius

        let circleTempView = UIView(frame: circleView.bounds)
        circleTempView.layer.addSublayer(circleGradientLayer)

        guard let blurredImage = circleTempView.applyBlur(with: circleBlurAmount) else { return }

        let boundingRect = CGRect(x: -circleBlurAmount * 4, y: -circleBlurAmount * 4, width: circleView.bounds.width + circleBlurAmount * 8, height: circleView.bounds.height + circleBlurAmount * 8)
        let circleBlurImageView = UIImageView(frame: boundingRect)
        circleBlurImageView.image = blurredImage

        NeuUIHelper.removeAllSubViews(view: circleView)
        circleView.addSubview(circleBlurImageView)
    }
    
    private func addContentShadow() {

        guard let shadowModel = state == .normal ? contentModel.normalShadowModel : contentModel.highlightedShadowModel else { return }
        
        let shadowLayer = CALayer()
        shadowLayer.frame = contentView.bounds
        shadowLayer.cornerRadius = contentView.layer.cornerRadius
        shadowLayer.masksToBounds = false
        shadowLayer.applyShadow(color: shadowModel.color, alpha: shadowModel.opacity, x: shadowModel.xOffset, y: shadowModel.yOffset, blur: shadowModel.blur, spread: shadowModel.spread)
        contentView.layer.addSublayer(shadowLayer)
    }
    
    private func addContentGradient() {
        
        guard let colors = state == .normal ? contentModel.normalBgGradientColors : contentModel.highlightedBgGradientColors else { return }
        contentView.layer.addSkewedGradientLayer(colors: colors)
    }
    
    private func addContentBorder() {

        guard let borderGradients = state == .normal ? contentModel.normalBorderGradients : contentModel.highlightedBorderGradients else { return }
        for borderGradient in borderGradients {
            contentView.layer.addSublayer(NeuUIHelper.borderGradientLayer(gradientModel: borderGradient, bounds: contentView.bounds, cornerRadius: contentView.layer.cornerRadius))
        }
    }

    private func addContentInnerShadow() {

        guard let innerShadows = state == .normal ? contentModel.normalInnerShadows : contentModel.highlightedInnerShadows else { return }
        for shadowModel in innerShadows {
            let shadowLayer = CALayer()
            shadowLayer.frame = contentView.bounds
            shadowLayer.cornerRadius = contentView.layer.cornerRadius
            shadowLayer.addInnerShadow(shadowColor: shadowModel.color, shadowOpacity: shadowModel.opacity, blur: shadowModel.blur, xOffset: shadowModel.xOffset, yOffset: shadowModel.yOffset)
            contentView.layer.addSublayer(shadowLayer)
        }
    }
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}
