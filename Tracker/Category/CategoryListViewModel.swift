import Foundation

struct CategoryCellViewModel {
    let title: String
    let isSelected: Bool
}

final class CategoryListViewModel {

    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?

    private(set) var categories: [CategoryCellViewModel] = []

    var isEmpty: Bool {
        categories.isEmpty
    }

    private let categoryStore: TrackerCategoryStore
    private var selectedCategoryTitle: String?

    init(categoryStore: TrackerCategoryStore, selectedCategoryTitle: String?) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
        categoryStore.delegate = self
        categories = makeCellViewModels()
    }

    func didSelectCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        let title = categories[index].title
        selectedCategoryTitle = title
        updateCategories()
        onCategorySelected?(title)
    }

    func makeNewCategoryViewModel() -> NewCategoryViewModel {
        let viewModel = NewCategoryViewModel()
        viewModel.onCategoryCreated = { [weak self] title in
            self?.addCategory(title: title)
        }
        return viewModel
    }

    private func addCategory(title: String) {
        do {
            try categoryStore.addCategory(title: title)
        } catch {
            print("Не удалось сохранить категорию: \(error)")
        }
    }

    private func updateCategories() {
        categories = makeCellViewModels()
        onCategoriesChanged?()
    }

    private func makeCellViewModels() -> [CategoryCellViewModel] {
        categoryStore.categories.map { category in
            CategoryCellViewModel(
                title: category.title,
                isSelected: category.title == selectedCategoryTitle
            )
        }
    }
}

extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate(_ store: TrackerCategoryStore) {
        updateCategories()
    }
}
