import SwiftUI

public struct RegView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreementChecked = false

    @State private var nameError: String? = nil
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var isLoading = false
    @State private var showingConsentDialog = false

    @FocusState private var focusedField: Field?
    private enum Field { case name, email, password }

    public init() {}

    public var body: some View {
        ZStack {
            Color.clear.hooplabAurora()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Заголовок (matches acc_reg)
                    Text(dataStore.isEnglish ? "Registration" : "Регистрация")
                        .font(.geist(HooplabDimens.textDisplay, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                        .padding(.top, 64)
                        .padding(.bottom, 28)

                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dataStore.isEnglish ? "Name" : "Name")
                            .font(.geist(HooplabDimens.textBody, weight: .semibold))
                            .foregroundColor(HooplabTheme.textSecondary)

                        TextField(dataStore.isEnglish ? "your name" : "your name", text: $name)
                            .focused($focusedField, equals: .name)
                            .font(.geist(HooplabDimens.textBody, weight: .semibold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .frame(height: HooplabDimens.inputHeight)
                            .background(HooplabTheme.bgInput)
                            .cornerRadius(HooplabDimens.radiusField)
                            .overlay(
                                RoundedRectangle(cornerRadius: HooplabDimens.radiusField)
                                    .stroke(focusedField == .name ? HooplabTheme.primary : (nameError != nil ? HooplabTheme.error : HooplabTheme.glassStroke),
                                            lineWidth: focusedField == .name ? 2 : 1)
                            )

                        if let err = nameError {
                            Text(err).font(.geist(12, weight: .medium)).foregroundColor(HooplabTheme.error)
                        }
                    }
                    .padding(.horizontal, 32)

                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dataStore.isEnglish ? "Email" : "Email")
                            .font(.geist(HooplabDimens.textBody, weight: .semibold))
                            .foregroundColor(HooplabTheme.textSecondary)

                        TextField(dataStore.isEnglish ? "your email" : "your email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .email)
                            .font(.geist(HooplabDimens.textBody, weight: .semibold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .frame(height: HooplabDimens.inputHeight)
                            .background(HooplabTheme.bgInput)
                            .cornerRadius(HooplabDimens.radiusField)
                            .overlay(
                                RoundedRectangle(cornerRadius: HooplabDimens.radiusField)
                                    .stroke(focusedField == .email ? HooplabTheme.primary : (emailError != nil ? HooplabTheme.error : HooplabTheme.glassStroke),
                                            lineWidth: focusedField == .email ? 2 : 1)
                            )

                        if let err = emailError {
                            Text(err).font(.geist(12, weight: .medium)).foregroundColor(HooplabTheme.error)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 12)

                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dataStore.isEnglish ? "Password" : "Password")
                            .font(.geist(HooplabDimens.textBody, weight: .semibold))
                            .foregroundColor(HooplabTheme.textSecondary)

                        SecureField("******", text: $password)
                            .focused($focusedField, equals: .password)
                            .font(.geist(HooplabDimens.textBody, weight: .semibold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .frame(height: HooplabDimens.inputHeight)
                            .background(HooplabTheme.bgInput)
                            .cornerRadius(HooplabDimens.radiusField)
                            .overlay(
                                RoundedRectangle(cornerRadius: HooplabDimens.radiusField)
                                    .stroke(focusedField == .password ? HooplabTheme.primary : (passwordError != nil ? HooplabTheme.error : HooplabTheme.glassStroke),
                                            lineWidth: focusedField == .password ? 2 : 1)
                            )

                        if let err = passwordError {
                            Text(err).font(.geist(12, weight: .medium)).foregroundColor(HooplabTheme.error)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 12)

                    // Agreement Checkbox + clickable consent dialog link
                    HStack(alignment: .center, spacing: 10) {
                        Button(action: {
                            SoundAndHaptics.shared.vibrateClick()
                            agreementChecked.toggle()
                        }) {
                            Image(systemName: agreementChecked ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundColor(agreementChecked ? HooplabTheme.primary : HooplabTheme.textSecondary)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            showingConsentDialog = true
                        }) {
                            Text(consentAttributedText)
                                .font(.geist(HooplabDimens.textCaption, weight: .regular))
                                .multilineTextAlignment(.leading)
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 16)

                    // Зарегистрироваться
                    Button(action: performRegister) {
                        Text(isLoading
                             ? (dataStore.isEnglish ? "Registering…" : "Регистрация…")
                             : (dataStore.isEnglish ? "Sign up" : "Зарегистрироваться"))
                            .font(.geist(HooplabDimens.textButton, weight: .semibold))
                            .foregroundColor(HooplabTheme.textOnAccent)
                            .frame(maxWidth: .infinity)
                            .frame(height: HooplabDimens.buttonHeight)
                            .background(HooplabTheme.primary)
                            .cornerRadius(HooplabDimens.radiusButton)
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading)
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                    // Есть аккаунт? Авторизируйтесь
                    Button(action: {
                        SoundAndHaptics.shared.vibrateClick()
                        dismiss()
                    }) {
                        Text(dataStore.isEnglish ? "Have an account? Log in" : "Есть аккаунт? Авторизируйтесь")
                            .font(.geist(HooplabDimens.textBody, weight: .semibold))
                            .foregroundColor(HooplabTheme.textSecondary)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingConsentDialog) {
            NavigationStack {
                ZStack {
                    Color.clear.hooplabAurora()
                    ScrollView {
                        Text(agreementText)
                            .font(.geist(14, weight: .regular))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .lineSpacing(5)
                            .padding(20)
                    }
                }
                .navigationTitle(dataStore.isEnglish ? "Consent" : "Согласие на обработку ПД")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(dataStore.isEnglish ? "Close" : "Закрыть") {
                            showingConsentDialog = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(dataStore.isEnglish ? "Got it" : "Понятно") {
                            agreementChecked = true
                            showingConsentDialog = false
                        }
                        .font(.geist(15, weight: .bold))
                        .foregroundColor(HooplabTheme.primary)
                    }
                }
            }
        }
    }

    private var consentAttributedText: AttributedString {
        let prefix = dataStore.isEnglish ? "I " : "Я "
        let clickable = dataStore.isEnglish ? "agree to the processing of personal data" : "согласен на обработку персональных данных"
        var str = AttributedString(prefix + clickable)
        str.foregroundColor = HooplabTheme.textSecondary
        if let range = str.range(of: clickable) {
            str[range].foregroundColor = HooplabTheme.primary
            str[range].underlineStyle = .single
        }
        return str
    }

    private func performRegister() {
        SoundAndHaptics.shared.vibrateClick()
        focusedField = nil
        nameError = nil
        emailError = nil
        passwordError = nil

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            nameError = dataStore.isEnglish ? "Enter your name" : "Введите имя"
            return
        }
        if trimmedEmail.isEmpty {
            emailError = dataStore.isEnglish ? "Enter your email" : "Введите email"
            return
        }
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        if !emailPredicate.evaluate(with: trimmedEmail) {
            emailError = dataStore.isEnglish ? "Enter a valid email" : "Введите корректный email"
            return
        }
        if trimmedPass.isEmpty {
            passwordError = dataStore.isEnglish ? "Enter a password" : "Введите пароль"
            return
        }
        if trimmedPass.count < 6 {
            passwordError = dataStore.isEnglish ? "Password must be at least 6 characters" : "Пароль должен быть не менее 6 символов"
            return
        }
        if !agreementChecked {
            dataStore.showToast(dataStore.isEnglish ? "Please check the personal data consent box" : "Поставьте галочку согласия на обработку персональных данных")
            return
        }

        isLoading = true
        Task {
            let res = await dataStore.register(name: trimmedName, email: trimmedEmail, password: trimmedPass)
            isLoading = false
            switch res {
            case .success:
                dataStore.showToast(dataStore.isEnglish ? "Registration successful!" : "Регистрация успешна!")
                withAnimation(Animation.easeInOut(duration: 0.3)) {
                    dataStore.route = .main
                }
                dismiss()
            case .failure(let err):
                dataStore.showToast(err.localizedDescription)
            }
        }
    }

    private var agreementText: String {
        """
        СОГЛАСИЕ НА ОБРАБОТКУ ПЕРСОНАЛЬНЫХ ДАННЫХ

        1. ОБЩИЕ ПОЛОЖЕНИЯ

        1.1. Настоящее Согласие на обработку персональных данных (далее — «Согласие») составлено в соответствии с требованиями Федерального закона от 27.07.2006 № 152-ФЗ «О персональных данных» и определяет порядок обработки персональных данных и меры по обеспечению их безопасности, предпринимаемые оператором — приложением HoopsLab (далее — «Оператор»).

        1.2. Оператор ставит своей важнейшей целью и условием осуществления своей деятельности соблюдение прав и свобод человека и гражданина при обработке его персональных данных, в том числе защиты прав на неприкосновенность частной жизни, личную и семейную тайну.

        1.3. Настоящее Согласие применяется ко всей информации, которую Оператор может получить о Пользователе во время использования приложения HoopsLab.

        2. ПЕРСОНАЛЬНЫЕ ДАННЫЕ, КОТОРЫЕ ОБРАБАТЫВАЮТСЯ

        2.1. Оператор обрабатывает следующие персональные данные Пользователя:

        • Фамилия, имя (или псевдоним);
        • Адрес электронной почты (email);
        • Пароль (в зашифрованном виде);
        • Изображение профиля (аватар) — при желании Пользователя;
        • Данные о прогрессе тренировок и избранных упражнениях;
        • Технические данные: тип устройства, версия операционной системы, идентификатор устройства.

        2.2. Оператор НЕ обрабатывает специальные категории персональных данных, касающиеся расовой, национальной принадлежности, политических взглядов, религиозных или философских убеждений, состояния здоровья, интимной жизни.

        3. ЦЕЛИ ОБРАБОТКИ ПЕРСОНАЛЬНЫХ ДАННЫХ

        3.1. Персональные данные Пользователя обрабатываются в следующих целях:

        • Идентификация Пользователя для предоставления доступа к функционалу приложения;
        • Персонализация тренировочного процесса и рекомендаций;
        • Сохранение прогресса тренировок и истории активности;
        • Обеспечение обратной связи и технической поддержки;
        • Улучшение качества работы приложения и разработка новых функций;
        • Отправка уведомлений (при согласии Пользователя).

        4. ПРАВОВЫЕ ОСНОВАНИЯ ОБРАБОТКИ

        4.1. Оператор обрабатывает персональные данные Пользователя только в случае их заполнения и/или отправки Пользователем самостоятельно через формы регистрации в приложении.

        4.2. Заполняя соответствующие формы и/или отправляя свои персональные данные Оператору, Пользователь выражает свое согласие с данной Политикой.

        4.3. Оператор обрабатывает обезличенные данные о Пользователе в случае, если это разрешено в настройках браузера или устройства Пользователя.

        5. ПОРЯДОК И УСЛОВИЯ ОБРАБОТКИ ПЕРСОНАЛЬНЫХ ДАННЫХ

        5.1. Обработка персональных данных Пользователя осуществляется без ограничения срока, любым законным способом, в том числе в информационных системах персональных данных с использованием средств автоматизации или без использования таких средств.

        5.2. Пользователь соглашается с тем, что Оператор вправе передавать персональные данные третьим лицам исключительно в целях, указанных в разделе 3 настоящего Согласия.

        5.3. Персональные данные Пользователя могут быть переданы уполномоченным органам государственной власти Российской Федерации только по основаниям и в порядке, установленным законодательством Российской Федерации.

        5.4. Оператор принимает необходимые организационные и технические меры для защиты персональной информации Пользователя от неправомерного или случайного доступа, уничтожения, изменения, блокирования, копирования, распространения, а также от иных неправомерных действий третьих лиц.

        6. ПРАВА ПОЛЬЗОВАТЕЛЯ

        6.1. Пользователь имеет право:

        • Получать информацию, касающуюся обработки его персональных данных;
        • Требовать уточнения, блокирования или уничтожения своих персональных данных;
        • Отозвать согласие на обработку персональных данных;
        • Обжаловать действия или бездействие Оператора в уполномоченный орган по защите прав субъектов персональных данных или в судебном порядке.

        6.2. Для реализации своих прав Пользователь может обратиться к Оператору через форму обратной связи в приложении или по адресу электронной почты: support@hooplab.app

        7. ХРАНЕНИЕ И УНИЧТОЖЕНИЕ ПЕРСОНАЛЬНЫХ ДАННЫХ

        7.1. Персональные данные Пользователя хранятся на защищённых серверах и локальных устройствах с использованием шифрования.

        7.2. При удалении аккаунта все персональные данные Пользователя безвозвратно удаляются в течение 30 дней с момента запроса.

        7.3. Обезличенные данные могут храниться в аналитических целях неограниченное время.

        8. ЗАКЛЮЧИТЕЛЬНЫЕ ПОЛОЖЕНИЯ

        8.1. Оператор вправе вносить изменения в настоящее Согласие. Новая редакция вступает в силу с момента её размещения в приложении.

        8.2. Продолжение использования приложения после внесения изменений означает согласие Пользователя с новой редакцией.

        8.3. Настоящее Согласие действует бессрочно до момента отзыва согласия Пользователем.

        Дата последнего обновления: 14 сентября 2026 г.
        """
    }
}
