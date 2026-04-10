//
//  AlertView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 09/04/26.
//

import SwiftUI

enum AlertViewType {
    case delete
    case save
    case edit
    case cancel

    var title: String {
        switch self {
        case .delete:
            return String(localized: "common.delete")
        case .save:
            return String(localized: "common.save")
        case .edit:
            return String(localized: "common.edit")
        case .cancel:
            return String(localized: "common.cancel")
        }
    }
}

enum AlertViewOption {
    case cancel
    case confirm
}

func AlertView(
    title: String,
    message: String,
    type: AlertViewType = .save,
    completion: @escaping (_ result: AlertViewOption) -> Void
) -> Alert {
    .init(
        title: Text(title),
        message: Text(message),
        primaryButton: .default(
            Text("common.cancel"),
            action: {
                completion(.cancel)
            }
        ),
        secondaryButton: .destructive(
            Text(type.title),
            action: {
                completion(.confirm)
            }
        )
    )
}
