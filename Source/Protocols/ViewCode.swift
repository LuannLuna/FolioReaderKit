//
//  ViewCode.swift
//  AEXML
//
//  Created by Luann Luna on 17/04/23.
//

import Foundation

protocol ViewCodable {
    func setup()
    func setupViews()
    func setupAnchors()
    func setupLayouts()
}

extension ViewCodable {

    func setup() {
        setupViews()
        setupAnchors()
        setupLayouts()
    }

    func setupLayouts() {}

}
