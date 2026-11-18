import UIKit

final class NewCategoryViewController: UIViewController {

    private let viewModel: NewCategoryViewModel

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
        field.font = .systemFont(ofSize: 17)
        field.textColor = .blackDay
        field.backgroundColor = .backgroundDay
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let doneButton = ActionButton(title: "Готово", style: .primary)

    init(viewModel: NewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(didChangeName), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        setupLayout()
        bind()
        doneButton.isEnabled = viewModel.isDoneEnabled
    }

    private func setupLayout() {
        view.addSubviews([titleLabel, nameField, doneButton])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func bind() {
        viewModel.onDoneEnabledChanged = { [weak self] isEnabled in
            self?.doneButton.isEnabled = isEnabled
        }
    }

    @objc private func didChangeName() {
        viewModel.didChangeName(nameField.text ?? "")
    }

    @objc private func didTapDone() {
        guard viewModel.isDoneEnabled else { return }
        viewModel.didTapDone()
        dismiss(animated: true)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        return viewModel.canChangeName(to: updatedText)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        viewModel.didChangeName("")
        return false
    }
}
