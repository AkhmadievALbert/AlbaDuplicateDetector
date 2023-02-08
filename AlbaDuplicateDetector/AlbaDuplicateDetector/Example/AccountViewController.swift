//
//  AccountViewController.swift
//  SMEAccounts
//
//  Created by s.erokhin on 01/04/2019.
//  Copyright © 2019 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

import SMELog
import SMEOperations
import SMEUIComponents
import SMEUIKit
import SMEUtils
import TinkoffDesignKit
import UIKit

typealias OperationDisplayData = LegacyOperationTableViewCell.DisplayData
typealias MonthCashFlowDisplayData = ThreeLabelsTableHeaderView1.DisplayData
typealias MonthCashFlowDebitOrCreditDisplayData = TwoLabelsTableHeaderView.DisplayData
extension AccountInfoDisplayData: AccountTitleFloatingViewDisplayDataProtocol {}
extension AccountView.Action: AccountActionButtonProtocol {}

final class AccountViewController: UIViewController {
    private enum Constants {
        enum View {
            static let initialHeight: CGFloat = 182
            static let finalHeight: CGFloat = 44
        }

        enum OperationCell {
            static let height: CGFloat = 90
            static let separatorInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        }
    }

    private enum StaticSections: CaseIterable {
        case banners
        case marketingOffers
        case search
    }

    // MARK: Private properties

    private let output: AccountViewOutput
    private lazy var operationsLoadingView: LoaderFooterView = {
        let view = LoaderFooterView()
        view.backgroundColor = .tui.background.base
        view.refreshTintColor = .tui.foreground.neutralAccent
        view.isLoaderDislpayed = true
        return view
    }()

    private let firstOperationsSectionIndex = StaticSections.allCases.count
    private var banners: [AccountView.Banner] = []
    private var marketingOffers: [MarketingOfferCell.DisplayData] = []

    // MARK: Public properties

    weak var delegate: AnyAccountControllerDelegate?
    private(set) var accountActions: [AccountActionItem] = []

    // MARK: Outlets

    @IBOutlet private var titleFloatingView: AccountTitleFloatingView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var submittedPaymentsSumLabel: UILabel!
    @IBOutlet private var overdraftBalanceLabel: UILabel! {
        didSet {
            overdraftBalanceLabel.accessibilityIdentifier = Automation.header(.overdraftBalance).label
        }
    }

    @IBOutlet private var overdraftDebtLabel: UILabel! {
        didSet {
            overdraftDebtLabel.accessibilityIdentifier = Automation.header(.overdraftDebt).label
        }
    }

    @IBOutlet private var overdraftLastDateExpiredLabel: UILabel! {
        didSet {
            overdraftLastDateExpiredLabel.text = Strings.account_info_overdraft_last_date_expired()
            overdraftLastDateExpiredLabel.textColor = UIColor.sk.n14
            overdraftLastDateExpiredLabel.font = UIFont.sk.regular(size: 12)
        }
    }

    // MARK: Lifecycle

    init(output: AccountViewOutput) {
        self.output = output
        let nib = Nib.accountViewController
        super.init(nibName: nib.name, bundle: nib.bundle)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewDidLoadEvent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTitleFloatingView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewDidAppearEvent()
    }

    // MARK: Private methods

    private func updateTitleFloatingView() {
        let delta = Constants.View.initialHeight - Constants.View.finalHeight
        let progress = 1 - min(1, max(0, view.frame.height - Constants.View.finalHeight) / delta)
        titleFloatingView.progress = progress
        stackView.transform = CGAffineTransform(translationX: 0, y: titleFloatingView.deltaHeight)
        stackView.alpha = 1 - min(1, progress * 8)
    }

    private func operationIndexPath(_ indexPath: IndexPath) -> IndexPath {
        IndexPath(row: indexPath.row, section: indexPath.section - firstOperationsSectionIndex)
    }

    private func bannerCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        switch banners[indexPath.row] {
        case let .overdraft(type):
            let cell = tableView.dequeueReusableCell(for: OverdraftCell.self, indexPath: indexPath)
            let descriptionText: String

            switch type {
            case .amount:
                descriptionText = Strings.overdraft_notification_amount()

            case .date:
                descriptionText = Strings.overdraft_notification_date()
            }

            let handler: () -> Void = { [weak self] in
                self?.output.viewDidTapOverdraftNotification(type, closed: true)
            }
            cell.accessibilityIdentifier = Automation.banner(.overdraft).label
            cell.configure(
                with: .init(
                    titleText: Strings.overdraft_title(),
                    descriptionText: descriptionText
                ),
                closeHandler: handler
            )
            return cell

        case let .arrests(displayData):
            let cell = tableView.dequeueReusableCell(for: TCSTableViewContainerCellBase<ArrestsCellView>.self, indexPath: indexPath)
            cell.accessibilityIdentifier = Automation.banner(.arrests).label
            cell.configure(with: displayData)
            return cell

        case let .requisitions(displayData):
            let cell = tableView.dequeueReusableCell(for: RequisitionsCell.self, indexPath: indexPath)
            cell.accessibilityIdentifier = Automation.banner(.requisition).label
            cell.configure(with: displayData)
            return cell
        }
    }

    private func marketingOfferCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: MarketingOfferCell.self, indexPath: indexPath)
        let displayData = marketingOffers[indexPath.row]
        cell.configure(with: displayData)
        return cell
    }

    private func operationCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            for: LegacyOperationTableViewCell.self,
            indexPath: indexPath
        )
        if let displayData = output.operationDisplayData(at: operationIndexPath(indexPath)) {
            cell.configure(with: displayData)
            if indexPath.row == 0 {
                cell.separatorTypes = [.top(Constants.OperationCell.separatorInsets)]
            } else {
                cell.separatorTypes = []
            }
            cell.accessibilityIdentifier = Automation.feed(.operationItem).label
        } else {
            Log.error("No display data for operation")
        }
        return cell
    }

    private func calculateHeight(for banner: AccountView.Banner) -> CGFloat {
        switch banner {
        case .arrests:
            return UITableView.automaticDimension

        case .requisitions:
            return RequisitionsCell.height

        case .overdraft:
            return OverdraftCell.height
        }
    }

    private func calculatePlaceholderCellHeight(for tableView: UITableView) -> CGFloat {
        var height = tableView.frame.height
        height -= tableView.tableHeaderView?.frame.height ?? 0
        height -= tableView.adjustedContentInset.top + tableView.adjustedContentInset.bottom
        height -= banners.reduce(0, { $0 + calculateHeight(for: $1) })
        return max(height, 100)
    }

    private func dequeueCellForSearchBar(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: FiltersAndSearchCell.self, indexPath: indexPath)
        cell.configure(displayData: output.filtersAndSearchDisplayData())
        return cell
    }
}

// MARK: - AccountViewInput

extension AccountViewController: AccountViewInput {

    func showBanners(_ banners: [AccountView.Banner]) {
        self.banners = banners
        delegate?.reloadTableView()
    }

    func showActions(_ actions: [AccountView.Action]) {
        accountActions = actions.map { action -> AccountActionItem in
            AccountActionItem(action) { [weak self] in
                self?.output.viewDidTapAction(action)
            }
        }
        delegate?.reloadActionBar()
    }

    func showMarketingOffers(_ displayData: [MarketingOfferCell.DisplayData]) {
        marketingOffers = displayData
        delegate?.reloadTableView()
    }

    func updateFeed() {
        delegate?.reloadTableView()
    }

    func showAccountInfo(_ displayData: AccountInfoDisplayData) {
        titleFloatingView.configure(displayData)

        if let submittedPaymentsSum = displayData.submittedPaymentsSum, submittedPaymentsSum.decimalValue > 0 {
            submittedPaymentsSumLabel.attributedText = submittedPaymentsSum.formattedString
            submittedPaymentsSumLabel.isHidden = false
        } else {
            submittedPaymentsSumLabel.isHidden = true
        }

        if displayData.overdraft.availability != nil {
            overdraftBalanceLabel.attributedText = displayData.overdraft.formattedAvailability
            overdraftBalanceLabel.isHidden = false
        } else {
            overdraftBalanceLabel.isHidden = true
        }

        if displayData.overdraft.debt != nil {
            overdraftDebtLabel.attributedText = displayData.overdraft.formattedDebt
            overdraftDebtLabel.isHidden = false
        } else {
            overdraftDebtLabel.isHidden = true
        }

        overdraftLastDateExpiredLabel.isHidden = !displayData.overdraft.isLastDateExpired
    }

    func updateAdditionalOperationsLoadingState(_ isLoading: Bool) {
        let footerView = isLoading ? operationsLoadingView : nil
        delegate?.updateTableFooterView(footerView)
    }
}

// MARK: - AnyAccountControllerProtocol

extension AccountViewController: AnyAccountControllerProtocol {
    var gradientColors: [UIColor] {
        [UIColor.sk.sme1, UIColor.sk.sme2]
    }

    var footerView: UIView? {
        nil
    }

    var tableViewDataSource: UITableViewDataSource? {
        self
    }

    var tableViewDelegate: UITableViewDelegate? {
        self
    }

    func registerViewModels(for tableView: UITableView) {
        let cells: [UITableViewCell.Type] = [
            MarketingOfferCell.self,
            OperationsFeedShimmerCell.self,
            OneLabelHintCell.self,
            FiltersAndSearchCell.self,
            OverdraftCell.self,
            RequisitionsCell.self,
            TCSTableViewContainerCellBase<ArrestsCellView>.self
        ]

        tableView.register(
            UINib(resource: SMEOperations.Nib.legacyOperationTableViewCell),
            forCellReuseIdentifier: LegacyOperationTableViewCell.smeReuseIdentifier
        )
        tableView.registerCells(for: cells)
        tableView.register(
            TCSTableViewContainerCellBase<ArrestsCellView>.self,
            forCellReuseIdentifier: TCSTableViewContainerCellBase<ArrestsCellView>.smeReuseIdentifier
        )
        tableView.register(
            MarketingOfferCell.self,
            forCellReuseIdentifier: MarketingOfferCell.smeReuseIdentifier
        )

        let headerViews: [UITableViewHeaderFooterView.Type] = [
            ThreeLabelsTableHeaderView1.self,
            TwoLabelsTableHeaderView.self
        ]
        tableView.registerHeaderFooterViews(for: headerViews)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .sk.dynamic.background.separator
    }
}

// MARK: - UITableViewDataSource

extension AccountViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch output.feedState {
        case .loading, .placeholder, .error:
            return firstOperationsSectionIndex + 1

        case let .data(hasFilteredOperations):
            if hasFilteredOperations {
                return firstOperationsSectionIndex + output.numberOfOperationSections
            } else {
                return firstOperationsSectionIndex + 1
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 ..< firstOperationsSectionIndex:
            switch StaticSections.allCases[section] {
            case .banners:
                return banners.count

            case .marketingOffers:
                return marketingOffers.count

            case .search:
                if case .data = output.feedState {
                    return 1
                } else {
                    return 0
                }
            }

        default:
            switch output.feedState {
            case .loading, .placeholder, .error:
                return 1

            case .data(hasFilteredOperations: true):
                return output.numberOfOperations(inSection: section - firstOperationsSectionIndex)

            case .data(hasFilteredOperations: false):
                return 1
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 ..< firstOperationsSectionIndex:
            switch StaticSections.allCases[indexPath.section] {
            case .banners:
                return bannerCell(for: tableView, at: indexPath)

            case .marketingOffers:
                return marketingOfferCell(for: tableView, at: indexPath)

            case .search:
                return dequeueCellForSearchBar(tableView: tableView, indexPath: indexPath)
            }

        default:
            switch output.feedState {
            case let .data(hasFilteredOperations):
                if hasFilteredOperations {
                    return operationCell(for: tableView, at: indexPath)
                } else {
                    let cell = tableView.dequeueReusableCell(for: OneLabelHintCell.self)
                    cell.configure(with: OneLabelHintCell.DisplayData(title: Strings.no_operations()))
                    return cell
                }

            case let .placeholder(text), let
                .error(text):
                let cell = tableView.dequeueReusableCell(for: OneLabelHintCell.self)
                cell.configure(with: OneLabelHintCell.DisplayData(title: text))
                return cell

            case .loading:
                let cell = tableView.dequeueReusableCell(for: OperationsFeedShimmerCell.self, indexPath: indexPath)
                cell.accessibilityIdentifier = Automation.feed(.shimmerItem).label
                return cell
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0 ..< firstOperationsSectionIndex:
            switch StaticSections.allCases[indexPath.section] {
            case .banners:
                switch banners[indexPath.row] {
                case let .overdraft(type):
                    output.viewDidTapOverdraftNotification(type, closed: false)

                case .arrests:
                    output.viewDidTapArrests()

                case .requisitions:
                    output.viewDidTapRequisitions()
                }

            case .marketingOffers:
                break

            case .search:
                break
            }

        default:
            if case .data = output.feedState {
                output.viewDidTapOperation(at: operationIndexPath(indexPath))
            }
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0 ..< firstOperationsSectionIndex:
            return StaticSections.allCases[indexPath.section] != .marketingOffers

        default:
            return true
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        func headerForData(hasFilteredOperations: Bool) -> UIView? {
            guard hasFilteredOperations else {
                return nil
            }

            let resultHeaderView: UITableViewHeaderFooterView
            let actualSectionIndex = section - firstOperationsSectionIndex

            if output.isDebitOrCreditFilterSelected {
                let headerView = tableView.dequeueReusableHeaderFooterView(for: TwoLabelsTableHeaderView.self)
                if let displayData = output.monthCashFlowDebitOrCreditDisplayData(for: actualSectionIndex) {
                    headerView.configure(with: displayData)
                } else {
                    return nil
                }

                resultHeaderView = headerView

            } else {
                let headerView = tableView.dequeueReusableHeaderFooterView(for: ThreeLabelsTableHeaderView1.self)
                if let displayData = output.monthCashFlowDisplayData(for: actualSectionIndex) {
                    headerView.configure(with: displayData)
                } else {
                    return nil
                }

                resultHeaderView = headerView
            }

            resultHeaderView.accessibilityIdentifier = Automation.feed(.cashFlowHeader).label

            return resultHeaderView
        }

        switch section {
        case 0 ..< firstOperationsSectionIndex:
            switch StaticSections.allCases[section] {
            case .banners:
                return nil
            case .marketingOffers:
                return nil
            case .search:
                return UIView()
            }

        default:
            switch output.feedState {
            case .loading, .placeholder, .error:
                return nil

            case let .data(hasFilteredOperations):
                return headerForData(hasFilteredOperations: hasFilteredOperations)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0 ..< firstOperationsSectionIndex:
            switch StaticSections.allCases[section] {
            case .banners:
                return .leastNormalMagnitude

            case .marketingOffers:
                return .leastNormalMagnitude

            case .search:
                return section > 0 ? 1 : 7
            }

        default:
            switch output.feedState {
            case let .data(hasFilteredOperations):
                if hasFilteredOperations {
                    return ThreeLabelsTableHeaderView1.height()
                } else {
                    return .leastNormalMagnitude
                }

            default:
                return .leastNormalMagnitude
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0 ..< firstOperationsSectionIndex:
            switch StaticSections.allCases[indexPath.section] {
            case .banners:
                return calculateHeight(for: banners[indexPath.row])

            case .marketingOffers:
                return UITableView.automaticDimension

            case .search:
                return FiltersAndSearchCell.height
            }

        default:
            switch output.feedState {
            case let .data(hasFilteredOperations):
                if hasFilteredOperations {
                    return Constants.OperationCell.height
                } else {
                    return calculatePlaceholderCellHeight(for: tableView) - FiltersAndSearchCell.height
                }

            case .loading:
                return OperationsFeedShimmerCell.height()

            case .placeholder, .error:
                return calculatePlaceholderCellHeight(for: tableView)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension AccountViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        output.viewDidScrolled()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let isScrolledToTheBottom = scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height

        if case .data = output.feedState, isScrolledToTheBottom {
            output.viewReachedEndOfFeed()
        }
    }
}
