//
//  DevicesView.swift
//  BankingApp
//
//  Muestra los dispositivos registrados
//  para el cliente autenticado.
//

import SwiftUI


struct DevicesView: View {


    // MARK: - Properties

    let customerId: Int


    // MARK: - Devices

    private var devices: [Device] {

        MockData.devices
            .filter {
                device in

                device.customerId ==
                    customerId
            }
    }


    // MARK: - Body

    var body: some View {

        List {

            if devices.isEmpty {

                ContentUnavailableView(
                    "Sin dispositivos",
                    systemImage:
                        "iphone.slash",
                    description:
                        Text(
                            "No existen dispositivos registrados para este cliente."
                        )
                )

            } else {

                ForEach(devices) {
                    device in

                    deviceRow(device)
                }
            }
        }
        .navigationTitle(
            "Dispositivos"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }


    // MARK: - Device Row

    private func deviceRow(
        _ device: Device
    ) -> some View {

        HStack(spacing: 14) {

            Image(
                systemName:
                    deviceIcon(
                        for: device
                    )
            )
            .font(.title2)
            .frame(width: 32)


            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(device.name)
                    .fontWeight(
                        .medium
                    )


                Text(
                    device.isTrusted
                    ? "Dispositivo confiable"
                    : "Dispositivo no confiable"
                )
                .font(.caption)
                .foregroundStyle(
                    device.isTrusted
                    ? Color.secondary
                    : Color.orange
                )
            }


            Spacer()


            Image(
                systemName:
                    device.isTrusted
                    ? "checkmark.shield.fill"
                    : "exclamationmark.shield.fill"
            )
            .foregroundStyle(
                device.isTrusted
                ? Color.green
                : Color.orange
            )
        }
        .padding(
            .vertical,
            4
        )
    }


    // MARK: - Device Icon

    private func deviceIcon(
        for device: Device
    ) -> String {

        switch device.type {

        case .iPhone:

            return "iphone.gen3"

        case .iPad:

            return "ipad"
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        DevicesView(
            customerId: 1
        )
    }
}
