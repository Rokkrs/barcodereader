//
//  ButtonView.swift
//  SSCaseStudy
//
//  Created by Oscar Hooman on 7/13/24.
//

import Foundation
import SwiftUI

struct ButtonView: View {
    let label: String
    let icon: String?
    let action: () -> Void

    init(
        label: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.action = action
    }
    
//    var body: some View {
//        Button {
//            action()
//        } label: {
//            if let icon {
//                Image(systemName: icon)
//            }
//            Text(label)
//        }
//    }
    var body: some View {
            Button {
                action()
            } label: {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                    Text(label)
                }
                .font(.title2)
                .padding(.vertical, 12)
                .foregroundColor(Color.purple)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple, lineWidth: 2.0)
                      .background {
                          RoundedRectangle(cornerRadius: 12)
                              .fill(Color.purple.opacity(0.2))
                      }
                }
            }
        }
}


struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(label: "OK") {}
    }
}

struct ClaimButton: View {
    let configuration: Configuration
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon = configuration.icon {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                if configuration.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(configuration.textColor)
                }
                Text(configuration.text)
            }
            .padding(12)
            .font(.title2)
            .foregroundColor(configuration.textColor)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(configuration.borderColor, lineWidth: 2.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(configuration.backgroundColor)
                    }
            }
        }
        .disabled(configuration.disabled)
    }
}

extension ClaimButton {
    struct Configuration {
        let icon: String?
        let text: String
        let textColor: Color
        let backgroundColor: Color
        let borderColor: Color
        let isLoading: Bool
        let disabled: Bool

        // Initializer with default values
        init(
            icon: String? = nil,
            text: String,
            textColor: Color = .purple,
            backgroundColor: Color = .purple.opacity(0.2),
            borderColor: Color = .purple,
            isLoading: Bool = false,
            disabled: Bool = false
        ) {
            self.icon = icon
            self.text = text
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.isLoading = isLoading
            self.disabled = disabled
        }
        
        // Default (normal) state
        static var normal: Configuration {
            Configuration(
                text: "Claim Coupon"
            )
        }

        // Loading state
        static var loading: Configuration {
            Configuration(
                text: "Claiming...",
                isLoading: true,
                disabled: true
            )
        }

        // Disabled state
        static var disabled: Configuration {
            Configuration(
                text: "Claim Coupon",
                textColor: .secondary,
                backgroundColor: .secondary.opacity(0.2),
                borderColor: .secondary.opacity(0.7),
                disabled: true
            )
        }

        // Confirmed state
        static var confirmed: Configuration {
            Configuration(
                icon: "checkmark.circle.fill",
                text: "Claimed!",
                textColor: .green,
                backgroundColor: .green.opacity(0.2),
                borderColor: .green,
                disabled: true
            )
        }
    }
}
