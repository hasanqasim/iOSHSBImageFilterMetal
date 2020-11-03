//
//  ViewController.swift
//  HSBFilter
//
//  Created by Hasan Qasim on 2/11/20.
//

import UIKit
import MetalKit
import CoreImage


class MetalViewController: UIViewController {
    
    // Metal resources
    var metalView: MTKView!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var sourceTexture: MTLTexture!
    
    // Core Image resources
    var context: CIContext!
    var filter: CIFilter!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    var hue: Float!
    var saturation: Float!
    var brightness: Float!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemGray5
        initDefaultGPU()
        sourceTexture = loadMetalTexture()
        context = CIContext(mtlDevice: device)
        filter = initFilter()
        initMetalView()
        addLeftBarButton()
        
        HandleDoubleTap()
    }
    
    @objc func doubleTapped() {
        hue = 0
        saturation = 1
        brightness = 0
    }
    
    @objc func barButtonItemClicked() {
        let vc = HSBFilterViewController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

// MARK: Image Filtering
extension MetalViewController {
    
    func HandleDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
    }
    
    func addLeftBarButton() {
        let adjustHSBButton = UIBarButtonItem(title: "Adjust HSB", style: .plain, target: self, action: #selector(barButtonItemClicked))
        adjustHSBButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "SFUIDisplay-Semibold", size: 22)!,
                                                NSAttributedString.Key.foregroundColor : UIColor.black,], for: .normal)
        self.navigationItem.setLeftBarButton(adjustHSBButton, animated: true)
    }
    
    func initDefaultGPU() {
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
            commandQueue = self.device.makeCommandQueue()
        }
    }
    
    func loadMetalTexture() -> MTLTexture {
        let loader = MTKTextureLoader(device: device)
        do {
            let texture = try loader.newTexture(name: "Neon-Source",
                                                scaleFactor: UIScreen.main.nativeScale,
                                                bundle: Bundle.main,
                                                options:[MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.bottomLeft])
            return texture
        } catch(let error) {
            fatalError("Error when loading image: \(error.localizedDescription)")
        }
    }
    
    func initFilter() -> CIFilter? {
        brightness = 0
        saturation = 1
        hue = 0
        
        let filter = CIFilter(name: "CIColorControls", parameters: [kCIInputBrightnessKey : brightness!,
                                                                kCIInputSaturationKey : saturation!])
        return filter!
    }
        
    func initMetalView() {
        metalView = MTKView()
        metalView.delegate = self
        metalView.device = device
        metalView.framebufferOnly = false
        self.view.addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        metalView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        //metalView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 128).isActive = true
        //metalView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -128).isActive = true
        
        metalView.heightAnchor.constraint(equalToConstant: 256).isActive = true
        metalView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        metalView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    
    func applyFilterChain(to image: CIImage) -> CIImage? {
        filter.setValuesForKeys([kCIInputImageKey: image, kCIInputBrightnessKey : brightness!, kCIInputSaturationKey : saturation!])
        guard let brightenedANDSaturatedOutputCIImage = filter.outputImage else {
            return nil
        }
        let hueCIImage = brightenedANDSaturatedOutputCIImage.applyingFilter("CIHueAdjust", parameters: [kCIInputAngleKey : hue!])
        return hueCIImage
    }
}

// MARK: Controller Transitioning delegate
extension MetalViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: slider did move delegate
extension MetalViewController: SliderDidMoveDelegate {
    func hueSliderMoved(sliderValue: Float) {
        hue = sliderValue
    }
    
    func saturationSliderMoved(sliderValue: Float) {
        saturation = sliderValue
    }
    
    func brightnessSliderMoved(sliderValue: Float) {
        brightness = sliderValue
    }
}

// MARK: Metal View delegate
extension MetalViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        if let currentDrawable = view.currentDrawable {
            let commandBuffer = commandQueue.makeCommandBuffer()
            let inputImage = CIImage(mtlTexture: sourceTexture)
            
            view.drawableSize = inputImage!.extent.size
        
            let filteredImage = applyFilterChain(to: inputImage!)
            //filteredImage = filteredImage!.transformed(by: filteredImage!.orientationTransform(for: .downMirrored))
            
            context.render(filteredImage!,
                    to: currentDrawable.texture,
                    commandBuffer: commandBuffer,
                    bounds: inputImage!.extent, //self.view.bounds, //inputImage!.extent,
                    colorSpace: colorSpace)
            
            commandBuffer!.present(currentDrawable)
            commandBuffer!.commit()
        }
    }
}







