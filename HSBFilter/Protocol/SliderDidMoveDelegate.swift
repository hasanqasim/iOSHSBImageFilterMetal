//
//  sliderDidMoveDelegate.swift
//  HSBFilter
//
//  Created by Hasan Qasim on 2/11/20.
//

import Foundation

protocol SliderDidMoveDelegate {
    func hueSliderMoved(sliderValue: Float)
    func saturationSliderMoved(sliderValue: Float)
    func brightnessSliderMoved(sliderValue: Float)
}
