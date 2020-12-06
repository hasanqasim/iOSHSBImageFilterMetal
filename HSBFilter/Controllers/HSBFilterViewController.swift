//
//  HSBFilterViewController.swift
//  HSBFilter
//
//  Created by Hasan Qasim on 2/11/20.
//

import UIKit

class HSBFilterViewController: UIViewController {
    
    weak var delegate: SliderDidMoveDelegate?
    
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: CGRect(x:0, y:0, width: self.view.bounds.width, height: 30))
        bdView.backgroundColor = UIColor.systemBackground
        return bdView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        modifyView()
        createSubview()
        
        let hueStack = getLabelANDSliderHStack(text: "Hue", min: -Float.pi, max: Float.pi, defaultValue: 0, action: #selector(self.hueSliderValueDidChange(_:)))
        let saturationStack = getLabelANDSliderHStack(text: "Saturation", min: 0, max: 2, defaultValue: 1, action: #selector(self.saturationSliderValueDidChange(_:)))
        let brightnessStack = getLabelANDSliderHStack(text: "Brightness", min: -1, max: 1, defaultValue: 0, action: #selector(self.brightnessSliderValueDidChange(_:)))
        
        addVerticalStackView(stackOne: hueStack, stackTwo: saturationStack, stackThree: brightnessStack)
        
        addDismissLabel()
        
        handleDismissTap()
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func hueSliderValueDidChange(_ sender:UISlider!) {
        if let sliderMoveDelegate = delegate {
            sliderMoveDelegate.hueSliderMoved(sliderValue: sender.value)
        }
     }
    
    @objc func saturationSliderValueDidChange(_ sender:UISlider!) {
        if let sliderMoveDelegate = delegate {
            sliderMoveDelegate.saturationSliderMoved(sliderValue: sender.value)
        }
     }
        
    @objc func brightnessSliderValueDidChange(_ sender:UISlider!) {
        if let sliderMoveDelegate = delegate {
            sliderMoveDelegate.brightnessSliderMoved(sliderValue: sender.value)
        }
     }
}

// MARK: label, slider and views
extension HSBFilterViewController {
    
    func handleDismissTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    func modifyView() {
        self.view.backgroundColor = .systemBackground
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
        self.view.addSubview(backdropView)
    }
    
    func createSubview() {
        let subview = UIView()
        subview.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
              return .systemGray5
            default:
              return #colorLiteral(red: 0.9413269353, green: 0.9413269353, blue: 0.9413269353, alpha: 1)
            }
        }
        subview.layer.cornerRadius = 15
        view.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.heightAnchor.constraint(equalToConstant: 124).isActive = true
        subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8).isActive = true
        subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8).isActive = true
        subview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32).isActive = true
    }

    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "SFUIText-Regular", size: 15)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }
    
    func createSlider(min: Float, max: Float, defaultValue: Float) -> UISlider {
        let slider = UISlider()
        slider.value = defaultValue
        slider.minimumValue = min
        slider.maximumValue = max
        slider.isContinuous = true
        return slider
    }
    
    func addDismissLabel() {
        let label = createLabel(text: "Dismiss")
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 22)
        //
        label.textColor = .label
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 6).isActive = true
    }
    
}

// MARK: UIStack Views
extension HSBFilterViewController {
    
    func addVerticalStackView(stackOne: UIStackView, stackTwo: UIStackView, stackThree: UIStackView) {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.spacing = 10
        stackView.addArrangedSubview(stackOne)
        stackView.addArrangedSubview(stackTwo)
        stackView.addArrangedSubview(stackThree)
        self.view.addSubview(stackView)
        
        //Constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40).isActive = true
    }
    
    
    func getLabelANDSliderHStack(text: String, min: Float, max: Float, defaultValue: Float, action: Selector) -> UIStackView {
        let label = createLabel(text: text)
        let slider = createSlider(min: min, max: max, defaultValue: defaultValue)
        slider.addTarget(self, action: action, for: .valueChanged)
        let hStackView = addHorizontalStackView(label: label, slider: slider)
        return hStackView
    }
    
    func addHorizontalStackView(label: UILabel, slider: UISlider) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 0
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(slider)
        return stackView
    }
}

