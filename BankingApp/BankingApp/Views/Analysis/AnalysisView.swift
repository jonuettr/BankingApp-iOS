//
//  AnalysisView.swift
//  BankingApp
//
//  Dashboard financiero del cliente.
//

import SwiftUI
import Charts


struct AnalysisView: View {

    // MARK: - View Model

    @State private var viewModel:
        AnalysisViewModel


    init(customerId: Int) {

        _viewModel = State(
            initialValue:
                AnalysisViewModel(
                    customerId: customerId
                )
        )
    }


    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {


                    // MARK: - Summary

                    Text("Resumen financiero")
                        .font(.title2)
                        .fontWeight(.bold)

                    LazyVGrid(
                        columns: [
                            GridItem(
                                .adaptive(
                                    minimum: 150
                                )
                            )
                        ],
                        spacing: 12
                    ) {

                        summaryCard(
                            title: "Ingresos",
                            amount:
                                viewModel.totalIncome,
                            icon:
                                "arrow.down.circle.fill"
                        )

                        summaryCard(
                            title: "Gastos",
                            amount:
                                viewModel.totalExpenses,
                            icon:
                                "arrow.up.circle.fill"
                        )

                        summaryCard(
                            title: "Balance neto",
                            amount:
                                viewModel.netCashFlow,
                            icon:
                                "equal.circle.fill"
                        )
                    }


                    // MARK: - Expenses Chart

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        Text("Gastos por categoría")
                            .font(.title3)
                            .fontWeight(.bold)


                        if viewModel
                            .expensesByCategory
                            .isEmpty {

                            ContentUnavailableView(
                                "Sin gastos",
                                systemImage:
                                    "chart.bar",
                                description:
                                    Text(
                                        "Todavía no hay información suficiente para generar el análisis."
                                    )
                            )

                        } else {

                            Chart(
                                viewModel
                                    .expensesByCategory
                            ) { summary in

                                BarMark(

                                    x: .value(
                                        "Categoría",
                                        viewModel.categoryName(
                                            summary.category
                                        )
                                    ),

                                    y: .value(
                                        "Gasto",
                                        decimalToDouble(
                                            summary.amount
                                        )
                                    )
                                )
                            }
                            .frame(height: 250)
                        }
                    }
                    .padding()
                    .background(
                        Color(
                            .secondarySystemBackground
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )


                    // MARK: - Category Detail

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        Text("Detalle por categoría")
                            .font(.title3)
                            .fontWeight(.bold)


                        ForEach(
                            viewModel.expensesByCategory
                        ) { summary in

                            categoryRow(summary)

                            if summary.id !=
                                viewModel
                                    .expensesByCategory
                                    .last?.id {

                                Divider()
                            }
                        }
                    }
                    .padding()
                    .background(
                        Color(
                            .secondarySystemBackground
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )
                }
                .padding()
            }
            .navigationTitle("Análisis")

            .onAppear {

                viewModel.refresh()
            }
        }
    }


    // MARK: - Summary Card

    private func summaryCard(
        title: String,
        amount: Decimal,
        icon: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Image(systemName: icon)
                .font(.title2)


            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)


            Text(
                amount,
                format:
                    .currency(code: "MXN")
            )
            .font(.headline)
            .fontWeight(.bold)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }


    // MARK: - Category Row

    private func categoryRow(
        _ summary: CategorySummary
    ) -> some View {

        VStack(spacing: 8) {

            HStack {

                Label(
                    viewModel.categoryName(
                        summary.category
                    ),
                    systemImage:
                        categoryIcon(
                            summary.category
                        )
                )


                Spacer()


                Text(
                    summary.amount,
                    format:
                        .currency(code: "MXN")
                )
                .fontWeight(.semibold)
            }


            HStack {

                Text(
                    viewModel
                        .expensePercentage(
                            for: summary.amount
                        ),
                    format: .percent
                        .precision(
                            .fractionLength(1)
                        )
                )
                .font(.caption)
                .foregroundStyle(.secondary)


                Spacer()
            }

            ProgressView(
                value:
                    decimalToDouble(
                        viewModel
                            .expensePercentage(
                                for: summary.amount
                            )
                    )
            )
        }
        .padding(.vertical, 4)
    }


    // MARK: - Category Icon

    private func categoryIcon(
        _ category: TransactionCategory
    ) -> String {

        switch category {

        case .income:
            return "banknote.fill"

        case .food:
            return "fork.knife"

        case .transportation:
            return "car.fill"

        case .entertainment:
            return "play.tv.fill"

        case .shopping:
            return "bag.fill"

        case .services:
            return "doc.text.fill"

        case .health:
            return "cross.case.fill"

        case .transfers:
            return "arrow.left.arrow.right"

        case .financial:
            return "creditcard.fill"

        case .other:
            return "ellipsis.circle.fill"
        }
    }


    // MARK: - Decimal Conversion

    private func decimalToDouble(
        _ decimal: Decimal
    ) -> Double {

        NSDecimalNumber(
            decimal: decimal
        ).doubleValue
    }
}


// MARK: - Preview

#Preview {
    AnalysisView(customerId: 1)
}
