import SwiftUI

public struct AuthView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var isLoading = false
    @State private var showingReg = false
    @State private var showingResetSheet = false
    @State private var resetEmail = ""

    @FocusState private var focusedField: Field?
    private enum Field { case email, password }

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.hooplabAurora()

                VStack(spacing: 0) {
                    Spacer(minLength: 40)

                    // Заголовок (matches acc_auth)
                    Text(dataStore.isEnglish ? "Sign in to your account" : "Войдите в аккаунт")
                        .font(.geist(HooplabDimens.textDisplay, weight: .bold))
                        .foregroundColor(HooplabTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

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
                            Text(err)
                                .font(.geist(12, weight: .medium))
                                .foregroundColor(HooplabTheme.error)
                        }
                    }
                    .padding(.horizontal, 32)

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
                            Text(err)
                                .font(.geist(12, weight: .medium))
                                .foregroundColor(HooplabTheme.error)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)

                    // Забыли пароль?
                    HStack {
                        Spacer()
                        Button(action: {
                            SoundAndHaptics.shared.vibrateClick()
                            resetEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                            showingResetSheet = true
                        }) {
                            Text(dataStore.isEnglish ? "Forgot password?" : "Забыли пароль?")
                                .font(.geist(HooplabDimens.textCaption, weight: .semibold))
                                .foregroundColor(HooplabTheme.primary)
                                .padding(8)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                    // Кнопка "Войти в аккаунт"
                    Button(action: performLogin) {
                        Text(isLoading
                             ? (dataStore.isEnglish ? "Loading..." : "Загрузка...")
                             : (dataStore.isEnglish ? "Sign in" : "Войти в аккаунт"))
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
                    .padding(.top, 16)

                    // Кнопка "Войти через Google" (glass_card)
                    Button(action: {
                        SoundAndHaptics.shared.vibrateClick()
                        dataStore.showToast(dataStore.isEnglish ? "Google Sign-In unavailable on iOS without OAuth" : "Google Sign-In недоступен — войдите по Email")
                    }) {
                        Text(dataStore.isEnglish ? "Sign in with Google" : "Войти через Google")
                            .font(.geist(HooplabDimens.textButton, weight: .semibold))
                            .foregroundColor(HooplabTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: HooplabDimens.buttonHeight)
                            .background(HooplabTheme.glassFill)
                            .cornerRadius(HooplabDimens.radiusCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: HooplabDimens.radiusCard)
                                    .stroke(HooplabTheme.glassStroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)

                    Spacer()

                    // Ссылка на регистрацию
                    Button(action: {
                        SoundAndHaptics.shared.vibrateClick()
                        showingReg = true
                    }) {
                        Text(dataStore.isEnglish ? "No account? Create one" : "Нет аккаунта? Создайте")
                            .font(.geist(HooplabDimens.textBody, weight: .semibold))
                            .foregroundColor(HooplabTheme.textSecondary)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showingReg) {
                RegView()
                    .environmentObject(dataStore)
            }
            .alert(dataStore.isEnglish ? "Password Reset" : "Восстановление пароля", isPresented: $showingResetSheet) {
                TextField(dataStore.isEnglish ? "your email" : "your email", text: $resetEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                Button(dataStore.isEnglish ? "Send Link" : "Отправить ссылку") {
                    let target = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                    if target.isEmpty {
                        dataStore.showToast(dataStore.isEnglish ? "Enter your email" : "Введите email")
                    } else {
                        Task {
                            let res = await dataStore.sendPasswordReset(email: target)
                            switch res {
                            case .success:
                                dataStore.showToast(dataStore.isEnglish ? "Password reset email has been sent to your inbox!" : "Письмо со ссылкой для сброса пароля отправлено на ваш email!")
                            case .failure(let err):
                                dataStore.showToast(err.localizedDescription)
                            }
                        }
                    }
                }
                Button(dataStore.isEnglish ? "Cancel" : "Отмена", role: .cancel) {}
            } message: {
                Text(dataStore.isEnglish ? "Enter your account email to receive a password reset link:" : "Введите email вашего аккаунта для сброса пароля:")
            }
        }
    }

    private func performLogin() {
        SoundAndHaptics.shared.vibrateClick()
        focusedField = nil
        emailError = nil
        passwordError = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            emailError = dataStore.isEnglish ? "Enter your email" : "Введите email"
            return
        }
        if trimmedPass.isEmpty {
            passwordError = dataStore.isEnglish ? "Enter a password" : "Введите пароль"
            return
        }

        isLoading = true
        Task {
            let res = await dataStore.login(email: trimmedEmail, password: trimmedPass)
            isLoading = false
            switch res {
            case .success:
                dataStore.showToast(dataStore.isEnglish ? "Welcome!" : "Добро пожаловать!")
                withAnimation(.easeInOut(duration: 0.3)) {
                    dataStore.route = .main
                }
            case .failure(let err):
                dataStore.showToast(err.localizedDescription)
            }
        }
    }
}
