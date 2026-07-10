import AppKit
import Darwin
import FanCore
import Foundation

private let requiredHelperProtocolVersion = "2026-07-08.2"

private enum L10n {
    enum Key: Hashable {
        case appName
        case overview
        case memory
        case disk
        case battery
        case charging
        case network
        case fanSpeedControl
        case system
        case max
        case speed
        case quit
        case noFans
        case errorPrefix
        case helperInstallFailed
        case controlFailedRPMRange
        case controlFailedPermission
        case controlFailed
        case helperMissing
        case helperSocketFailed
        case helperNotRunning
        case helperWriteFailed
        case helperReadFailed
    }

    private enum Language: Hashable {
        case en
        case zhHans
        case zhHant
        case ja
        case ko
        case es
        case fr
        case de
        case pt
        case ru
    }

    static func text(_ key: Key) -> String {
        translations[language]?[key] ?? translations[.en]?[key] ?? ""
    }

    private static let language: Language = {
        for rawIdentifier in Locale.preferredLanguages {
            let identifier = rawIdentifier.lowercased()
            if identifier.hasPrefix("zh-hant") || identifier.hasPrefix("zh-tw") || identifier.hasPrefix("zh-hk") || identifier.hasPrefix("zh-mo") {
                return .zhHant
            }
            if identifier.hasPrefix("zh") {
                return .zhHans
            }
            if identifier.hasPrefix("ja") {
                return .ja
            }
            if identifier.hasPrefix("ko") {
                return .ko
            }
            if identifier.hasPrefix("es") {
                return .es
            }
            if identifier.hasPrefix("fr") {
                return .fr
            }
            if identifier.hasPrefix("de") {
                return .de
            }
            if identifier.hasPrefix("pt") {
                return .pt
            }
            if identifier.hasPrefix("ru") {
                return .ru
            }
            if identifier.hasPrefix("en") {
                return .en
            }
        }
        return .en
    }()

    private static let translations: [Language: [Key: String]] = [
        .en: [
            .appName: "MacBoard",
            .overview: "Overview",
            .memory: "Memory",
            .disk: "Disk",
            .battery: "Battery",
            .charging: "Charging",
            .network: "Network",
            .fanSpeedControl: "Fan Speed Control",
            .system: "System",
            .max: "Max",
            .speed: "Speed",
            .quit: "Quit",
            .noFans: "No fans detected",
            .errorPrefix: "Error",
            .helperInstallFailed: "Install helper failed",
            .controlFailedRPMRange: "Control failed: RPM outside hardware range",
            .controlFailedPermission: "Control failed: helper needs permission",
            .controlFailed: "Control failed",
            .helperMissing: "fanhelper was not bundled in the app.",
            .helperSocketFailed: "socket failed",
            .helperNotRunning: "helper is not running",
            .helperWriteFailed: "write failed",
            .helperReadFailed: "read failed"
        ],
        .zhHans: [
            .appName: "MacBoard",
            .overview: "概览",
            .memory: "内存",
            .disk: "磁盘",
            .battery: "电池",
            .charging: "充电中",
            .network: "网络",
            .fanSpeedControl: "风扇转速控制",
            .system: "系统",
            .max: "最大",
            .speed: "转速",
            .quit: "退出",
            .noFans: "未检测到风扇",
            .errorPrefix: "错误",
            .helperInstallFailed: "辅助服务安装失败",
            .controlFailedRPMRange: "控制失败：转速超出硬件范围",
            .controlFailedPermission: "控制失败：辅助服务需要权限",
            .controlFailed: "控制失败",
            .helperMissing: "应用中未包含 fanhelper。",
            .helperSocketFailed: "socket 失败",
            .helperNotRunning: "辅助服务未运行",
            .helperWriteFailed: "写入失败",
            .helperReadFailed: "读取失败"
        ],
        .zhHant: [
            .appName: "MacBoard",
            .overview: "概覽",
            .memory: "記憶體",
            .disk: "磁碟",
            .battery: "電池",
            .charging: "充電中",
            .network: "網路",
            .fanSpeedControl: "風扇轉速控制",
            .system: "系統",
            .max: "最大",
            .speed: "轉速",
            .quit: "結束",
            .noFans: "未偵測到風扇",
            .errorPrefix: "錯誤",
            .helperInstallFailed: "輔助服務安裝失敗",
            .controlFailedRPMRange: "控制失敗：轉速超出硬體範圍",
            .controlFailedPermission: "控制失敗：輔助服務需要權限",
            .controlFailed: "控制失敗",
            .helperMissing: "App 中未包含 fanhelper。",
            .helperSocketFailed: "socket 失敗",
            .helperNotRunning: "輔助服務未執行",
            .helperWriteFailed: "寫入失敗",
            .helperReadFailed: "讀取失敗"
        ],
        .ja: [
            .appName: "MacBoard",
            .overview: "概要",
            .memory: "メモリ",
            .disk: "ディスク",
            .battery: "バッテリー",
            .charging: "充電中",
            .network: "ネットワーク",
            .fanSpeedControl: "ファン速度制御",
            .system: "システム",
            .max: "最大",
            .speed: "速度",
            .quit: "終了",
            .noFans: "ファンが検出されません",
            .errorPrefix: "エラー",
            .helperInstallFailed: "ヘルパーのインストールに失敗",
            .controlFailedRPMRange: "制御失敗: RPM が範囲外です",
            .controlFailedPermission: "制御失敗: ヘルパー権限が必要です",
            .controlFailed: "制御失敗",
            .helperMissing: "fanhelper がアプリに含まれていません。",
            .helperSocketFailed: "socket 失敗",
            .helperNotRunning: "ヘルパーが実行されていません",
            .helperWriteFailed: "書き込み失敗",
            .helperReadFailed: "読み取り失敗"
        ],
        .ko: [
            .appName: "MacBoard",
            .overview: "개요",
            .memory: "메모리",
            .disk: "디스크",
            .battery: "배터리",
            .charging: "충전 중",
            .network: "네트워크",
            .fanSpeedControl: "팬 속도 제어",
            .system: "시스템",
            .max: "최대",
            .speed: "속도",
            .quit: "종료",
            .noFans: "팬을 찾을 수 없음",
            .errorPrefix: "오류",
            .helperInstallFailed: "헬퍼 설치 실패",
            .controlFailedRPMRange: "제어 실패: RPM이 범위를 벗어남",
            .controlFailedPermission: "제어 실패: 헬퍼 권한 필요",
            .controlFailed: "제어 실패",
            .helperMissing: "앱에 fanhelper가 포함되어 있지 않습니다.",
            .helperSocketFailed: "socket 실패",
            .helperNotRunning: "헬퍼가 실행 중이 아님",
            .helperWriteFailed: "쓰기 실패",
            .helperReadFailed: "읽기 실패"
        ],
        .es: [
            .appName: "MacBoard",
            .overview: "Resumen",
            .memory: "Memoria",
            .disk: "Disco",
            .battery: "Bateria",
            .charging: "Cargando",
            .network: "Red",
            .fanSpeedControl: "Control de velocidad",
            .system: "Sistema",
            .max: "Max",
            .speed: "Velocidad",
            .quit: "Salir",
            .noFans: "No se detectaron ventiladores",
            .errorPrefix: "Error",
            .helperInstallFailed: "Error al instalar el helper",
            .controlFailedRPMRange: "Error de control: RPM fuera de rango",
            .controlFailedPermission: "Error de control: el helper necesita permiso",
            .controlFailed: "Error de control",
            .helperMissing: "fanhelper no esta incluido en la app.",
            .helperSocketFailed: "fallo de socket",
            .helperNotRunning: "el helper no se esta ejecutando",
            .helperWriteFailed: "fallo de escritura",
            .helperReadFailed: "fallo de lectura"
        ],
        .fr: [
            .appName: "MacBoard",
            .overview: "Apercu",
            .memory: "Memoire",
            .disk: "Disque",
            .battery: "Batterie",
            .charging: "En charge",
            .network: "Reseau",
            .fanSpeedControl: "Controle de vitesse",
            .system: "Systeme",
            .max: "Max",
            .speed: "Vitesse",
            .quit: "Quitter",
            .noFans: "Aucun ventilateur detecte",
            .errorPrefix: "Erreur",
            .helperInstallFailed: "Echec de l'installation du helper",
            .controlFailedRPMRange: "Echec du controle: RPM hors plage",
            .controlFailedPermission: "Echec du controle: autorisation requise",
            .controlFailed: "Echec du controle",
            .helperMissing: "fanhelper n'est pas inclus dans l'app.",
            .helperSocketFailed: "echec du socket",
            .helperNotRunning: "le helper n'est pas lance",
            .helperWriteFailed: "echec d'ecriture",
            .helperReadFailed: "echec de lecture"
        ],
        .de: [
            .appName: "MacBoard",
            .overview: "Uebersicht",
            .memory: "Speicher",
            .disk: "Festplatte",
            .battery: "Batterie",
            .charging: "Laedt",
            .network: "Netzwerk",
            .fanSpeedControl: "Luefterdrehzahl",
            .system: "System",
            .max: "Max",
            .speed: "Drehzahl",
            .quit: "Beenden",
            .noFans: "Keine Luefter erkannt",
            .errorPrefix: "Fehler",
            .helperInstallFailed: "Helper-Installation fehlgeschlagen",
            .controlFailedRPMRange: "Steuerung fehlgeschlagen: RPM ausserhalb des Bereichs",
            .controlFailedPermission: "Steuerung fehlgeschlagen: Helper braucht Rechte",
            .controlFailed: "Steuerung fehlgeschlagen",
            .helperMissing: "fanhelper ist nicht in der App enthalten.",
            .helperSocketFailed: "socket fehlgeschlagen",
            .helperNotRunning: "Helper laeuft nicht",
            .helperWriteFailed: "Schreiben fehlgeschlagen",
            .helperReadFailed: "Lesen fehlgeschlagen"
        ],
        .pt: [
            .appName: "MacBoard",
            .overview: "Visao geral",
            .memory: "Memoria",
            .disk: "Disco",
            .battery: "Bateria",
            .charging: "Carregando",
            .network: "Rede",
            .fanSpeedControl: "Controle de velocidade",
            .system: "Sistema",
            .max: "Max",
            .speed: "Velocidade",
            .quit: "Sair",
            .noFans: "Nenhuma ventoinha detectada",
            .errorPrefix: "Erro",
            .helperInstallFailed: "Falha ao instalar o helper",
            .controlFailedRPMRange: "Falha no controle: RPM fora do intervalo",
            .controlFailedPermission: "Falha no controle: helper precisa de permissao",
            .controlFailed: "Falha no controle",
            .helperMissing: "fanhelper nao esta incluido no app.",
            .helperSocketFailed: "falha de socket",
            .helperNotRunning: "helper nao esta em execucao",
            .helperWriteFailed: "falha de escrita",
            .helperReadFailed: "falha de leitura"
        ],
        .ru: [
            .appName: "MacBoard",
            .overview: "Обзор",
            .memory: "Память",
            .disk: "Диск",
            .battery: "Батарея",
            .charging: "Заряжается",
            .network: "Сеть",
            .fanSpeedControl: "Скорость вентилятора",
            .system: "Система",
            .max: "Макс",
            .speed: "Скорость",
            .quit: "Выход",
            .noFans: "Вентиляторы не найдены",
            .errorPrefix: "Ошибка",
            .helperInstallFailed: "Не удалось установить helper",
            .controlFailedRPMRange: "Ошибка управления: RPM вне диапазона",
            .controlFailedPermission: "Ошибка управления: helper требует права",
            .controlFailed: "Ошибка управления",
            .helperMissing: "fanhelper не включен в приложение.",
            .helperSocketFailed: "ошибка socket",
            .helperNotRunning: "helper не запущен",
            .helperWriteFailed: "ошибка записи",
            .helperReadFailed: "ошибка чтения"
        ]
    ]
}

@MainActor
final class FanMenuApp: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menuWidth = 320
    private var timer: Timer?
    private var latestFans: [Fan] = []
    private var latestTemperatures: [TemperatureReading] = []
    private var latestSystem: SystemSnapshot?
    private var latestError: String?
    private var isRefreshing = false
    private var isMenuOpen = false
    private var pendingFanTargetRPM: Int?
    private var pendingFanMode: FanControlMode?
    private var pendingFanTargetUntil: Date?
    private var selectedFanMode: FanControlMode?
    private var desiredFanTargetRPM: Int?
    private var isRunningHelperCommands = false
    private var isReapplyingFanIntent = false
    private var lastFanIntentReapplyAt = Date.distantPast
    private weak var currentOverviewView: SystemOverviewView?
    private weak var currentFanPanelView: FanPanelView?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "fan", accessibilityDescription: L10n.text(.appName))
            button.imagePosition = .imageLeading
            button.title = " ..."
            button.toolTip = L10n.text(.appName)
        }

        refresh()
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(refreshFromTimer), userInfo: nil, repeats: true)
        timer.tolerance = 0.2
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func refresh() {
        guard !isRefreshing else {
            return
        }
        isRefreshing = true

        Task.detached(priority: .utility) {
            let snapshot = FanMenuApp.readSnapshot()

            await MainActor.run { [weak self] in
                guard let self else {
                    return
                }
                if let errorMessage = snapshot.errorMessage {
                    self.latestError = errorMessage
                } else {
                self.latestFans = snapshot.fans
                self.latestTemperatures = snapshot.temperatures
                self.latestSystem = snapshot.system
                    self.latestError = nil
                }

                self.isRefreshing = false
                self.clearExpiredPendingFanTarget()
                self.maintainFanControlIntent()
                self.updateStatusTitle()
                if self.isMenuOpen {
                    self.updateOpenMenuViews()
                } else {
                    self.rebuildMenu()
                }
            }
        }
    }

    nonisolated private static func readSnapshot() -> RefreshSnapshot {
        let system = SystemMonitor.snapshot()
        guard let smc = try? SMC() else {
            return RefreshSnapshot(fans: [], temperatures: [], system: system, errorMessage: nil)
        }

        let controller = FanController(smc: smc)
        return RefreshSnapshot(
            fans: (try? controller.fans()) ?? [],
            temperatures: (try? controller.temperatures()) ?? [],
            system: system,
            errorMessage: nil
        )
    }

    private func updateStatusTitle() {
        guard latestError == nil else {
            statusItem.button?.title = " !"
            return
        }

        let values = [
            latestFans.first?.actualRPM.map { "\(Int($0.rounded()))" },
            latestTemperatures.map(\.celsius).max().map { "\(Int($0.rounded()))℃" }
        ].compactMap { $0 }
        statusItem.button?.title = values.isEmpty ? "" : " " + values.joined(separator: " ")
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.delegate = self
        currentOverviewView = nil
        currentFanPanelView = nil

        if let latestError {
            addView(ErrorRowView(text: menuTitle("\(L10n.text(.errorPrefix)): \(latestError)"), width: menuWidth), to: menu)
        } else {
            if let latestSystem {
                addSystemOverview(latestSystem, temperatures: groupedTemperatureRows(latestTemperatures), to: menu)
            }
            if !latestFans.isEmpty {
                if latestSystem != nil {
                    addView(MenuSeparatorView(width: menuWidth), to: menu)
                }
                addFanPanel(to: menu)
            }
        }

        addView(MenuSeparatorView(width: menuWidth), to: menu)
        menu.addItem(NSMenuItem(title: L10n.text(.quit), action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func updateOpenMenuViews() {
        if let latestSystem {
            currentOverviewView?.update(snapshot: latestSystem, temperatures: groupedTemperatureRows(latestTemperatures))
        }
        currentFanPanelView?.update(fans: latestFans, pendingTargetRPM: activePendingFanTarget(), pendingMode: currentFanModeForDisplay())
    }

    private func addFanPanel(to menu: NSMenu) {
        let panel = FanPanelView(
            fans: latestFans,
            pendingTargetRPM: activePendingFanTarget(),
            pendingMode: currentFanModeForDisplay(),
            width: menuWidth,
            onSystem: { [weak self] in self?.setSystemMode() },
            onMax: { [weak self] rpm in self?.setMaxMode(targetRPM: rpm) },
            onManual: { [weak self] rpm in self?.setManualSpeed(rpm: rpm) }
        )
        currentFanPanelView = panel
        addView(panel, to: menu)
    }

    private func addSystemOverview(_ snapshot: SystemSnapshot, temperatures: [(name: String, celsius: Double)], to menu: NSMenu) {
        let view = SystemOverviewView(snapshot: snapshot, temperatures: temperatures, width: menuWidth)
        currentOverviewView = view
        addView(view, to: menu)
    }

    private func groupedTemperatureRows(_ readings: [TemperatureReading]) -> [(name: String, celsius: Double)] {
        var groups: [String: Double] = [:]
        for reading in readings {
            let group = temperatureGroup(for: reading)
            groups[group] = max(groups[group] ?? -.infinity, reading.celsius)
        }

        let preferredOrder = ["CPU", "GPU", "Battery", "SSD", "Memory", "Thunderbolt", "Wireless", "Trackpad", "Power", "Other"]
        return groups
            .map { (name: $0.key, celsius: $0.value) }
            .filter { $0.name != "Other" }
            .sorted { lhs, rhs in
                let leftIndex = preferredOrder.firstIndex(of: lhs.name) ?? preferredOrder.count
                let rightIndex = preferredOrder.firstIndex(of: rhs.name) ?? preferredOrder.count
                if leftIndex == rightIndex {
                    return lhs.celsius > rhs.celsius
                }
                return leftIndex < rightIndex
            }
    }

    private func temperatureGroup(for reading: TemperatureReading) -> String {
        if reading.name.contains("CPU") ||
            reading.name.contains("Performance Core") ||
            reading.name.contains("Efficiency Core") {
            return "CPU"
        }
        if reading.name.contains("GPU") {
            return "GPU"
        }
        if reading.name.contains("Battery") {
            return "Battery"
        }
        if reading.name.contains("SSD") {
            return "SSD"
        }
        if reading.name.contains("Memory") {
            return "Memory"
        }
        if reading.name.contains("Thunderbolt") {
            return "Thunderbolt"
        }
        if reading.name.contains("Wireless") {
            return "Wireless"
        }
        if reading.name.contains("Trackpad") {
            return "Trackpad"
        }
        if reading.name.contains("Power") || reading.name.contains("Charger") {
            return "Power"
        }
        return "Other"
    }

    private func addView(_ view: NSView, to menu: NSMenu) {
        let item = NSMenuItem()
        item.view = view
        menu.addItem(item)
    }

    @objc private func refreshFromTimer() {
        refresh()
    }

    func menuWillOpen(_ menu: NSMenu) {
        isMenuOpen = true
    }

    func menuDidClose(_ menu: NSMenu) {
        isMenuOpen = false
        rebuildMenu()
    }

    @objc private func setSystemMode() {
        selectedFanMode = .system
        desiredFanTargetRPM = nil
        setPendingFanChange(targetRPM: nil, mode: .system)
        runHelperCommand("system")
    }

    private func setMaxMode(targetRPM: Int) {
        selectedFanMode = .max
        desiredFanTargetRPM = targetRPM
        setPendingFanChange(targetRPM: targetRPM, mode: .max)
        runHelperCommand("max")
    }

    private func setManualSpeed(rpm: Int) {
        selectedFanMode = .custom
        desiredFanTargetRPM = rpm
        setPendingFanChange(targetRPM: rpm, mode: .custom)
        let commands = latestFans.map { "manual \($0.index) \(rpm)" }
        runHelperCommands(commands.isEmpty ? ["manual-all \(rpm)"] : commands)
    }

    private func runHelperCommand(_ command: String) {
        runHelperCommands([command])
    }

    private func setPendingFanChange(targetRPM: Int?, mode: FanControlMode) {
        pendingFanTargetRPM = targetRPM
        pendingFanMode = mode
        pendingFanTargetUntil = Date().addingTimeInterval(6)
        currentFanPanelView?.setPendingFanChange(targetRPM: targetRPM, mode: mode)
    }

    private func activePendingFanTarget() -> Int? {
        clearExpiredPendingFanTarget()
        return pendingFanTargetRPM
    }

    private func activePendingFanMode() -> FanControlMode? {
        clearExpiredPendingFanTarget()
        return pendingFanMode
    }

    private func currentFanModeForDisplay() -> FanControlMode? {
        activePendingFanMode() ?? selectedFanMode
    }

    private func clearPendingFanChange() {
        pendingFanTargetRPM = nil
        pendingFanMode = nil
        pendingFanTargetUntil = nil
    }

    private func clearFanControlIntent() {
        clearPendingFanChange()
        selectedFanMode = nil
        desiredFanTargetRPM = nil
    }

    private func clearExpiredPendingFanTarget() {
        if let until = pendingFanTargetUntil, until < Date() {
            clearPendingFanChange()
        }
    }

    private func maintainFanControlIntent() {
        guard latestError == nil, !isRunningHelperCommands, !isReapplyingFanIntent else {
            return
        }
        guard selectedFanMode == .custom || selectedFanMode == .max, let targetRPM = desiredFanTargetRPM else {
            return
        }
        guard fanIntentNeedsReapply(targetRPM: targetRPM) else {
            return
        }

        let now = Date()
        guard now.timeIntervalSince(lastFanIntentReapplyAt) >= 2 else {
            return
        }

        isReapplyingFanIntent = true
        lastFanIntentReapplyAt = now

        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            defer {
                self.isReapplyingFanIntent = false
            }

            do {
                if try self.helperNeedsInstall() {
                    try self.installHelper()
                }

                let commands = self.latestFans.map { "manual \($0.index) \(targetRPM)" }
                for command in commands.isEmpty ? ["manual-all \(targetRPM)"] : commands {
                    let response = try self.sendHelperCommand(command)
                    if !response.hasPrefix("OK") {
                        self.clearFanControlIntent()
                        self.latestError = self.shortControlError(response)
                        self.refresh()
                        return
                    }
                }
            } catch let error as CustomStringConvertible {
                self.clearFanControlIntent()
                self.latestError = self.shortControlError(error.description)
            } catch {
                self.clearFanControlIntent()
                self.latestError = self.shortControlError(error.localizedDescription)
            }
        }
    }

    private func fanIntentNeedsReapply(targetRPM: Int) -> Bool {
        guard !latestFans.isEmpty else {
            return false
        }

        return latestFans.contains { fan in
            let targetMismatch = fan.targetRPM.map { abs($0 - Double(targetRPM)) > 100 } ?? true
            let actualStopped = (fan.actualRPM ?? 0) < 100 && targetRPM > Int((fan.minRPM ?? 0) + 100)
            return !fan.forced || targetMismatch || actualStopped
        }
    }

    private func runHelperCommands(_ commands: [String]) {
        guard !isRunningHelperCommands else {
            return
        }
        isRunningHelperCommands = true

        let needsAuthorization = (try? helperNeedsInstall()) ?? true
        guard needsAuthorization, isMenuOpen else {
            performHelperCommands(commands)
            return
        }

        // An authorization dialog opened from NSMenu's tracking loop can appear
        // without accepting keyboard focus. End menu tracking before requesting it.
        statusItem.menu?.cancelTracking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.performHelperCommands(commands)
        }
    }

    private func performHelperCommands(_ commands: [String]) {
        defer {
            isRunningHelperCommands = false
        }

        do {
            if try helperNeedsInstall() {
                try installHelper()
            }
        } catch {
            do {
                try installHelper()
            } catch let installError as CustomStringConvertible {
                latestError = "\(L10n.text(.helperInstallFailed)): \(installError.description)"
                refresh()
                return
            } catch {
                latestError = "\(L10n.text(.helperInstallFailed)): \(error.localizedDescription)"
                refresh()
                return
            }
        }

        do {
            for command in commands {
                let response = try sendHelperCommand(command)
                if !response.hasPrefix("OK") {
                    clearFanControlIntent()
                    latestError = shortControlError(response)
                    refresh()
                    return
                }
            }
            refresh()
        } catch let error as CustomStringConvertible {
            clearFanControlIntent()
            latestError = shortControlError(error.description)
            refresh()
        } catch {
            clearFanControlIntent()
            latestError = shortControlError(error.localizedDescription)
            refresh()
        }
    }

    private func helperNeedsInstall() throws -> Bool {
        let response = try sendHelperCommand("version")
        return !response.hasPrefix("OK fanhelper \(requiredHelperProtocolVersion)")
    }

    private func menuTitle(_ text: String, limit: Int = 42) -> String {
        guard text.count > limit else {
            return text
        }
        return String(text.prefix(limit - 1)) + "..."
    }

    private func shortControlError(_ text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: "ERR ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.contains("outside the hardware range") {
            return L10n.text(.controlFailedRPMRange)
        }
        if cleaned.contains("privilege") {
            return L10n.text(.controlFailedPermission)
        }
        return menuTitle("\(L10n.text(.controlFailed)): \(cleaned)", limit: 42)
    }

    private func sendHelperCommand(_ command: String) throws -> String {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd != -1 else {
            throw HelperError.socket(errno)
        }
        defer { close(fd) }

        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        withUnsafeMutableBytes(of: &address.sun_path) { rawBuffer in
            let bytes = Array("/var/run/fancontroller.sock".utf8.prefix(rawBuffer.count - 1))
            rawBuffer.copyBytes(from: bytes)
        }

        let connectResult = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
                connect(fd, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard connectResult != -1 else {
            throw HelperError.connect(errno)
        }

        let line = command + "\n"
        try line.withCString { pointer in
            if write(fd, pointer, strlen(pointer)) == -1 {
                throw HelperError.write(errno)
            }
        }

        var buffer = [UInt8](repeating: 0, count: 512)
        let count = read(fd, &buffer, buffer.count - 1)
        guard count > 0 else {
            throw HelperError.read(errno)
        }
        return String(decoding: buffer.prefix(Int(count)), as: UTF8.self)
    }

    private func installHelper() throws {
        guard let helper = bundledHelperPath() else {
            throw HelperError.notBundled
        }

        let installScript = """
        set -eu
        install -d -m 755 /Library/PrivilegedHelperTools
        install -m 755 \(shellQuoted(helper)) /Library/PrivilegedHelperTools/local.fan-controller.helper
        cat > /Library/LaunchDaemons/local.fan-controller.helper.plist <<'PLIST'
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>local.fan-controller.helper</string>
          <key>ProgramArguments</key>
          <array>
            <string>/Library/PrivilegedHelperTools/local.fan-controller.helper</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <true/>
        </dict>
        </plist>
        PLIST
        chown root:wheel /Library/LaunchDaemons/local.fan-controller.helper.plist /Library/PrivilegedHelperTools/local.fan-controller.helper
        chmod 644 /Library/LaunchDaemons/local.fan-controller.helper.plist
        chmod 755 /Library/PrivilegedHelperTools/local.fan-controller.helper
        launchctl bootout system /Library/LaunchDaemons/local.fan-controller.helper.plist >/dev/null 2>&1 || true
        launchctl bootstrap system /Library/LaunchDaemons/local.fan-controller.helper.plist
        """

        let script = "do shell script \(appleScriptQuoted(installScript)) with administrator privileges"
        var errorInfo: NSDictionary?
        guard NSAppleScript(source: script)?.executeAndReturnError(&errorInfo) != nil else {
            if let message = errorInfo?[NSAppleScript.errorMessage] as? String {
                throw HelperError.install(message)
            }
            throw HelperError.install("unknown error")
        }

        Thread.sleep(forTimeInterval: 0.5)
    }

    private func bundledHelperPath() -> String? {
        let helper = Bundle.main.bundleURL
            .appendingPathComponent("Contents/MacOS/fanhelper")
            .path
        return FileManager.default.isExecutableFile(atPath: helper) ? helper : nil
    }

    private func shellQuoted(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    private func appleScriptQuoted(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

private enum HelperError: Error, CustomStringConvertible {
    case notBundled
    case socket(Int32)
    case connect(Int32)
    case write(Int32)
    case read(Int32)
    case install(String)

    var description: String {
        switch self {
        case .notBundled:
            return L10n.text(.helperMissing)
        case .socket(let code):
            return "\(L10n.text(.helperSocketFailed)): \(String(cString: strerror(code)))"
        case .connect(let code):
            return "\(L10n.text(.helperNotRunning)): \(String(cString: strerror(code)))"
        case .write(let code):
            return "\(L10n.text(.helperWriteFailed)): \(String(cString: strerror(code)))"
        case .read(let code):
            return "\(L10n.text(.helperReadFailed)): \(String(cString: strerror(code)))"
        case .install(let message):
            return message
        }
    }
}

private struct RefreshSnapshot: Sendable {
    let fans: [Fan]
    let temperatures: [TemperatureReading]
    let system: SystemSnapshot?
    let errorMessage: String?
}

private enum FanControlMode: Sendable {
    case system
    case max
    case custom
}

@MainActor
private final class SystemOverviewView: NSView {
    private var cpuTile: MetricTileView?
    private var gpuTile: MetricTileView?
    private var memoryTile: MetricTileView?
    private var diskTile: MetricTileView?
    private var batteryTile: MetricTileView?
    private var networkTile: MetricTileView?

    override var isFlipped: Bool {
        true
    }

    init(snapshot: SystemSnapshot, temperatures: [(name: String, celsius: Double)], width: Int) {
        super.init(frame: NSRect(x: 0, y: 0, width: CGFloat(width), height: Self.preferredHeight(for: snapshot)))
        setup(snapshot: snapshot, temperatures: temperatures, width: width)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setup(snapshot: SystemSnapshot, temperatures: [(name: String, celsius: Double)], width: Int) {
        let temp = temperatureMap(temperatures)
        let header = SectionHeaderView(title: L10n.text(.overview), systemImage: "gauge.with.dots.needle.67percent", width: width)
        header.frame = NSRect(x: 0, y: 10, width: width, height: 30)
        addSubview(header)

        let cpu = snapshot.cpuLoad.map { cpuLoad in
            MetricTileView(
                title: "CPU",
                value: "\(Int((cpuLoad * 100).rounded()))%",
                detail: temp["CPU"].map { "\(Int($0.rounded()))℃" },
                progress: cpuLoad
            )
        }
        let memory = snapshot.memoryPercent.flatMap { memoryPercent -> MetricTileView? in
            guard let memoryUsed = snapshot.memoryUsed, let memoryTotal = snapshot.memoryTotal else {
                return nil
            }
            return MetricTileView(
                title: L10n.text(.memory),
                value: "\(Int((memoryPercent * 100).rounded()))%",
                detail: "\(formatBytes(memoryUsed)) / \(formatBytes(memoryTotal))",
                progress: memoryPercent
            )
        }
        let gpu = snapshot.gpuLoad.map {
            MetricTileView(
                title: "GPU",
                value: "\(Int(($0 * 100).rounded()))%",
                detail: temp["GPU"].map { "\(Int($0.rounded()))℃" },
                progress: $0
            )
        }
        let disk = snapshot.diskPercent.flatMap { diskPercent -> MetricTileView? in
            guard let diskUsed = snapshot.diskUsed, let diskTotal = snapshot.diskTotal else {
                return nil
            }
            return MetricTileView(
                title: L10n.text(.disk),
                value: "\(Int((diskPercent * 100).rounded()))%",
                detail: diskDetail(used: diskUsed, total: diskTotal, ssdTemperature: temp["SSD"]),
                progress: diskPercent
            )
        }
        let battery = snapshot.batteryPercent.map { percent in
            MetricTileView(
                title: L10n.text(.battery),
                value: "\(percent)%",
                detail: joinedDetail([
                    snapshot.isCharging == true ? L10n.text(.charging) : L10n.text(.battery),
                    temp["Battery"].map { "\(Int($0.rounded()))℃" }
                ]),
                progress: Double(percent) / 100
            )
        }
        let network = networkValues(snapshot).map { down, up in
            MetricTileView(
                title: L10n.text(.network),
                value: "",
                detail: networkDetail(down: down, up: up),
                progress: networkProgress(down: down, up: up)
            )
        }

        let tileWidth = CGFloat(width - 52) / 2
        let tileHeight: CGFloat = 38
        let tiles = [cpu, memory, gpu, disk, battery, network].compactMap { $0 }
        for (index, tile) in tiles.enumerated() {
            addSubview(tile)
            let column = index % 2
            let row = index / 2
            tile.frame = NSRect(
                x: 20 + CGFloat(column) * (tileWidth + 12),
                y: 46 + CGFloat(row) * 42,
                width: tileWidth,
                height: tileHeight
            )
        }

        cpuTile = cpu
        gpuTile = gpu
        memoryTile = memory
        diskTile = disk
        batteryTile = battery
        networkTile = network
    }

    func update(snapshot: SystemSnapshot, temperatures: [(name: String, celsius: Double)]) {
        let temp = temperatureMap(temperatures)
        if let cpuLoad = snapshot.cpuLoad {
            cpuTile?.isHidden = false
            cpuTile?.update(
                value: "\(Int((cpuLoad * 100).rounded()))%",
                detail: temp["CPU"].map { "\(Int($0.rounded()))℃" },
                progress: cpuLoad
            )
        } else {
            cpuTile?.isHidden = true
        }
        if let gpuLoad = snapshot.gpuLoad {
            gpuTile?.isHidden = false
            gpuTile?.update(
                value: "\(Int((gpuLoad * 100).rounded()))%",
                detail: temp["GPU"].map { "\(Int($0.rounded()))℃" },
                progress: gpuLoad
            )
        } else {
            gpuTile?.isHidden = true
        }
        if let memoryPercent = snapshot.memoryPercent,
           let memoryUsed = snapshot.memoryUsed,
           let memoryTotal = snapshot.memoryTotal {
            memoryTile?.isHidden = false
            memoryTile?.update(
                value: "\(Int((memoryPercent * 100).rounded()))%",
                detail: "\(formatBytes(memoryUsed)) / \(formatBytes(memoryTotal))",
                progress: memoryPercent
            )
        } else {
            memoryTile?.isHidden = true
        }
        if let diskPercent = snapshot.diskPercent,
           let diskUsed = snapshot.diskUsed,
           let diskTotal = snapshot.diskTotal {
            diskTile?.isHidden = false
            diskTile?.update(
                value: "\(Int((diskPercent * 100).rounded()))%",
                detail: diskDetail(used: diskUsed, total: diskTotal, ssdTemperature: temp["SSD"]),
                progress: diskPercent
            )
        } else {
            diskTile?.isHidden = true
        }
        if let batteryPercent = snapshot.batteryPercent {
            batteryTile?.isHidden = false
            batteryTile?.update(
                value: "\(batteryPercent)%",
                detail: joinedDetail([
                    snapshot.isCharging == true ? L10n.text(.charging) : L10n.text(.battery),
                    temp["Battery"].map { "\(Int($0.rounded()))℃" }
                ]),
                progress: Double(batteryPercent) / 100
            )
        } else {
            batteryTile?.isHidden = true
        }
        if let (down, up) = networkValues(snapshot) {
            networkTile?.isHidden = false
            networkTile?.update(
                value: "",
                detail: networkDetail(down: down, up: up),
                progress: networkProgress(down: down, up: up)
            )
        } else {
            networkTile?.isHidden = true
        }
    }

    private func temperatureMap(_ temperatures: [(name: String, celsius: Double)]) -> [String: Double] {
        Dictionary(uniqueKeysWithValues: temperatures.map { ($0.name, $0.celsius) })
    }

    private func diskDetail(used: UInt64, total: UInt64, ssdTemperature: Double?) -> String {
        joinedDetail([
            "\(formatBytes(used)) / \(formatBytes(total))",
            ssdTemperature.map { "\(Int($0.rounded()))℃" }
        ])
    }

    private func networkValues(_ snapshot: SystemSnapshot) -> (down: Double, up: Double)? {
        guard let down = snapshot.networkDownBytesPerSecond,
              let up = snapshot.networkUpBytesPerSecond else {
            return nil
        }
        return (down, up)
    }

    private func networkDetail(down: Double, up: Double) -> String {
        "↓ \(formatRate(down))  ↑ \(formatRate(up))"
    }

    private func networkProgress(down: Double, up: Double) -> Double {
        let total = down + up
        return min(1, max(0, total / (10 * 1024 * 1024)))
    }

    private func joinedDetail(_ parts: [String?]) -> String {
        parts.compactMap { $0 }.joined(separator: " • ")
    }

    private static func preferredHeight(for snapshot: SystemSnapshot) -> CGFloat {
        let metricCount = [
            snapshot.cpuLoad != nil,
            snapshot.memoryPercent != nil,
            snapshot.gpuLoad != nil,
            snapshot.diskPercent != nil,
            snapshot.batteryPercent != nil,
            snapshot.networkDownBytesPerSecond != nil && snapshot.networkUpBytesPerSecond != nil
        ].filter { $0 }.count
        let rowCount = (metricCount + 1) / 2
        return CGFloat(52 + rowCount * 42)
    }
}

@MainActor
private final class MetricTileView: NSView {
    private let title: String
    private var value: String
    private var detail: String?
    private var progress: Double

    override var isFlipped: Bool {
        true
    }

    init(title: String, value: String, detail: String? = nil, progress: Double) {
        self.title = title
        self.value = value
        self.detail = detail
        self.progress = max(0, min(1, progress))
        super.init(frame: .zero)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        nil
    }

    func update(value: String, detail: String? = nil, progress: Double) {
        self.value = value
        self.detail = detail
        self.progress = max(0, min(1, progress))
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor.secondaryLabelColor
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold),
            .foregroundColor: NSColor.labelColor
        ]
        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: NSColor.tertiaryLabelColor
        ]

        title.draw(at: NSPoint(x: 0, y: 0), withAttributes: titleAttributes)
        let valueSize = value.size(withAttributes: valueAttributes)
        value.draw(at: NSPoint(x: bounds.width - valueSize.width, y: 0), withAttributes: valueAttributes)

        if let detail {
            detail.draw(at: NSPoint(x: 0, y: 17), withAttributes: detailAttributes)
        }

        let track = NSRect(x: 0, y: bounds.height - 6, width: bounds.width, height: 4)
        NSColor.separatorColor.withAlphaComponent(0.45).setFill()
        NSBezierPath(roundedRect: track, xRadius: 2, yRadius: 2).fill()

        let fill = NSRect(x: 0, y: bounds.height - 6, width: bounds.width * progress, height: 4)
        NSColor.controlAccentColor.withAlphaComponent(0.9).setFill()
        NSBezierPath(roundedRect: fill, xRadius: 2, yRadius: 2).fill()
    }
}

@MainActor
private final class FanPanelView: NSView {
    private var fans: [Fan]
    private let onSystem: () -> Void
    private let onMax: (Int) -> Void
    private let onManual: (Int) -> Void
    private let slider = CommitSlider(value: 0, minValue: 0, maxValue: 100, target: nil, action: nil)
    private let rpmLabel = NSTextField(labelWithString: "")
    private let fanLabel = NSTextField(labelWithString: "")
    private let modeControl = NSSegmentedControl(
        labels: [L10n.text(.system), L10n.text(.max)],
        trackingMode: .selectOne,
        target: nil,
        action: nil
    )
    private var currentMode = ""
    private var pendingTargetRPM: Int?
    private var pendingMode: FanControlMode?
    private var pendingSliderCommit: DispatchWorkItem?
    private var lastCommittedSliderRPM: Int?

    override var isFlipped: Bool {
        true
    }

    init(
        fans: [Fan],
        pendingTargetRPM: Int?,
        pendingMode: FanControlMode?,
        width: Int,
        onSystem: @escaping () -> Void,
        onMax: @escaping (Int) -> Void,
        onManual: @escaping (Int) -> Void
    ) {
        self.fans = fans
        self.onSystem = onSystem
        self.onMax = onMax
        self.onManual = onManual
        self.pendingTargetRPM = pendingTargetRPM
        self.pendingMode = pendingMode
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: fans.isEmpty ? 78 : 142))
        setup(width: width)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setup(width: Int) {
        let header = SectionHeaderView(title: L10n.text(.fanSpeedControl), systemImage: "fan", width: width)
        header.frame = NSRect(x: 0, y: 10, width: width, height: 30)
        addSubview(header)

        guard !fans.isEmpty else {
            let empty = NSTextField(labelWithString: L10n.text(.noFans))
            empty.frame = NSRect(x: 20, y: 46, width: width - 40, height: 20)
            empty.font = .systemFont(ofSize: 13, weight: .regular)
            empty.textColor = .secondaryLabelColor
            addSubview(empty)
            return
        }

        let controlX: CGFloat = 40
        let controlWidth = CGFloat(width) - controlX * 2
        modeControl.frame = NSRect(x: controlX, y: 40, width: controlWidth, height: 30)
        modeControl.segmentStyle = .rounded
        modeControl.controlSize = .large
        modeControl.font = .systemFont(ofSize: 13, weight: .semibold)
        modeControl.setWidth(controlWidth / 2, forSegment: 0)
        modeControl.setWidth(controlWidth / 2, forSegment: 1)
        modeControl.target = self
        modeControl.action = #selector(modeChanged(_:))
        addSubview(modeControl)

        let targetValue = pendingTargetRPM.map(Double.init) ?? averageRPM(fans.compactMap(\.targetRPM))
        currentMode = fans.contains(where: { $0.forced }) ? "manual" : "system"
        updateModeButtons()

        fanLabel.stringValue = L10n.text(.speed)
        fanLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        fanLabel.textColor = .labelColor
        fanLabel.frame = NSRect(x: 20, y: 82, width: 76, height: 22)
        addSubview(fanLabel)

        rpmLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        rpmLabel.textColor = .secondaryLabelColor
        rpmLabel.alignment = .right
        rpmLabel.lineBreakMode = .byTruncatingTail
        rpmLabel.frame = NSRect(x: 104, y: 84, width: width - 124, height: 20)
        updateRPMLabel()
        addSubview(rpmLabel)

        slider.frame = NSRect(x: 20, y: 106, width: width - 40, height: 22)
        slider.target = self
        slider.action = #selector(sliderChanged(_:))
        slider.isContinuous = true
        slider.doubleValue = percentage(forRPM: targetValue ?? averageRPM(fans.compactMap(\.actualRPM)) ?? commonMinRPM)
        slider.onCommit = { [weak self] in
            self?.commitSlider()
        }
        addSubview(slider)
    }

    @objc private func modeChanged(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            systemPressed()
        case 1:
            maxPressed()
        default:
            break
        }
    }

    private func systemPressed() {
        lastCommittedSliderRPM = nil
        currentMode = "system"
        modeControl.selectedSegment = 0
        updateRPMLabel()
        onSystem()
    }

    private func maxPressed() {
        if commonMaxRPM > commonMinRPM {
            lastCommittedSliderRPM = nil
            let rpm = Int(commonMaxRPM.rounded())
            slider.doubleValue = percentage(forRPM: commonMaxRPM)
            currentMode = "manual"
            modeControl.selectedSegment = 1
            updateRPMLabel(targetRPM: rpm)
            onMax(rpm)
            return
        }
    }

    @objc private func sliderChanged(_ sender: NSSlider) {
        currentMode = "manual"
        modeControl.selectedSegment = -1
        updateRPMLabel()
        scheduleSliderCommit()
    }

    private func commitSlider() {
        guard !fans.isEmpty else {
            return
        }
        pendingSliderCommit?.cancel()
        pendingSliderCommit = nil
        let rpm = rpmForSlider()
        guard rpm != lastCommittedSliderRPM else {
            return
        }
        lastCommittedSliderRPM = rpm
        updateRPMLabel(targetRPM: rpm)
        onManual(rpm)
    }

    private func scheduleSliderCommit() {
        pendingSliderCommit?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            Task { @MainActor [weak self] in
                self?.commitSlider()
            }
        }
        pendingSliderCommit = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }

    private func percentage(forRPM rpm: Double) -> Double {
        guard commonMaxRPM > commonMinRPM else {
            return 0
        }
        return max(0, min(100, (rpm - commonMinRPM) / (commonMaxRPM - commonMinRPM) * 100))
    }

    private func rpmForSlider() -> Int {
        guard commonMaxRPM > commonMinRPM else {
            return Int((averageRPM(fans.compactMap(\.targetRPM)) ?? averageRPM(fans.compactMap(\.actualRPM)) ?? 0).rounded())
        }
        let raw = commonMinRPM + (commonMaxRPM - commonMinRPM) * slider.doubleValue / 100
        let rounded = (raw / 100).rounded() * 100
        return Int(max(commonMinRPM, min(commonMaxRPM, rounded)).rounded())
    }

    private func updateRPMLabel(targetRPM: Int? = nil) {
        guard !fans.isEmpty else {
            return
        }
        guard let actual = averageRPM(fans.compactMap(\.actualRPM)) else {
            fanLabel.isHidden = true
            rpmLabel.isHidden = true
            return
        }
        fanLabel.isHidden = false
        rpmLabel.isHidden = false
        rpmLabel.stringValue = "\(Int(actual.rounded())) RPM"
    }

    func update(fans: [Fan], pendingTargetRPM: Int?, pendingMode: FanControlMode?) {
        guard !fans.isEmpty else {
            return
        }
        self.fans = fans
        self.pendingTargetRPM = pendingTargetRPM
        self.pendingMode = pendingMode
        currentMode = pendingMode == .system ? "system" : (pendingTargetRPM != nil || fans.contains(where: { $0.forced }) ? "manual" : "system")
        fanLabel.stringValue = L10n.text(.speed)
        updateModeButtons()

        if !slider.isHighlighted {
            slider.doubleValue = percentage(
                forRPM: pendingTargetRPM.map(Double.init) ??
                    averageRPM(fans.compactMap(\.targetRPM)) ??
                    averageRPM(fans.compactMap(\.actualRPM)) ??
                    commonMinRPM
            )
        }
        updateRPMLabel()
    }

    func setPendingFanChange(targetRPM: Int?, mode: FanControlMode) {
        pendingTargetRPM = targetRPM
        pendingMode = mode
        currentMode = mode == .system ? "system" : "manual"
        updateModeButtons()
        if let targetRPM {
            slider.doubleValue = percentage(forRPM: Double(targetRPM))
        }
        updateRPMLabel(targetRPM: targetRPM)
    }

    private func updateModeButtons() {
        if pendingMode == .system {
            modeControl.selectedSegment = 0
            return
        }
        if pendingMode == .max {
            modeControl.selectedSegment = 1
            return
        }
        if pendingMode == .custom {
            modeControl.selectedSegment = -1
            return
        }
        if let pendingTargetRPM {
            modeControl.selectedSegment = commonMaxRPM > 0 && abs(Double(pendingTargetRPM) - commonMaxRPM) < 100 ? 1 : -1
            return
        }

        if !fans.contains(where: { $0.forced }) {
            modeControl.selectedSegment = 0
            return
        }

        let target = averageRPM(fans.compactMap(\.targetRPM)) ?? averageRPM(fans.compactMap(\.actualRPM)) ?? 0
        modeControl.selectedSegment = commonMaxRPM > 0 && abs(target - commonMaxRPM) < 100 ? 1 : -1
    }

    private var commonMinRPM: Double {
        fans.compactMap(\.minRPM).max() ?? 0
    }

    private var commonMaxRPM: Double {
        fans.compactMap(\.maxRPM).min() ?? 0
    }

    private func averageRPM(_ values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }
        return values.reduce(0, +) / Double(values.count)
    }
}

@MainActor
private final class CommitSlider: NSSlider {
    var onCommit: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        onCommit?()
    }

    override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        onCommit?()
    }
}

@MainActor
private final class SectionHeaderView: NSView {
    init(title: String, systemImage: String, width: Int) {
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 34))

        let icon = NSImageView()
        icon.image = NSImage(systemSymbolName: systemImage, accessibilityDescription: title)
        icon.contentTintColor = .secondaryLabelColor
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(icon)
        addSubview(label)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -18)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }
}

@MainActor
private final class InfoRowView: NSView {
    init(title: String, value: String, width: Int) {
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 25))

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = NSTextField(labelWithString: value)
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        valueLabel.textColor = .labelColor
        valueLabel.alignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }
}

@MainActor
private final class MenuSeparatorView: NSView {
    init(width: Int) {
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 10))

        let line = NSBox()
        line.boxType = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)

        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            line.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            line.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }
}

@MainActor
private class StatusMessageView: NSTextField {
    init(text: String, width: Int) {
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 26))
        stringValue = text
        isEditable = false
        isBordered = false
        drawsBackground = false
        font = .systemFont(ofSize: 12, weight: .medium)
        textColor = .secondaryLabelColor
        lineBreakMode = .byTruncatingTail
        cell?.wraps = false
        cell?.isScrollable = true
    }

    required init?(coder: NSCoder) {
        nil
    }
}

@MainActor
private final class ErrorRowView: StatusMessageView {}

@MainActor
private final class FanSliderView: NSView {
    private let fanIndex: Int
    private let minRPM: Double
    private let maxRPM: Double
    private let onCommit: (Int, Int) -> Void
    private let titleLabel = NSTextField(labelWithString: "")
    private let valueLabel = NSTextField(labelWithString: "")
    private let slider = NSSlider(value: 0, minValue: 0, maxValue: 100, target: nil, action: nil)

    init(fan: Fan, width: Int, onCommit: @escaping (Int, Int) -> Void) {
        self.fanIndex = fan.index
        self.minRPM = fan.minRPM ?? 0
        self.maxRPM = fan.maxRPM ?? 0
        self.onCommit = onCommit
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 76))
        setup(fan: fan)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setup(fan: Fan) {
        let currentRPM = fan.targetRPM ?? fan.actualRPM ?? minRPM
        slider.doubleValue = percentage(forRPM: currentRPM)
        slider.target = self
        slider.action = #selector(sliderChanged(_:))
        slider.isContinuous = true

        titleLabel.stringValue = "Fan \(fanIndex) Speed"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .labelColor

        valueLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        valueLabel.textColor = .secondaryLabelColor
        valueLabel.alignment = .right

        for view in [titleLabel, valueLabel, slider] {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),

            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            valueLabel.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),

            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        ])

        updateValueLabel()
    }

    @objc private func sliderChanged(_ sender: NSSlider) {
        updateValueLabel()

        guard let event = NSApp.currentEvent else {
            return
        }

        if event.type == .leftMouseUp || event.type == .keyUp {
            onCommit(fanIndex, rpmForCurrentPercentage())
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        onCommit(fanIndex, rpmForCurrentPercentage())
    }

    private func updateValueLabel() {
        let rpm = rpmForCurrentPercentage()
        valueLabel.stringValue = "\(rpm) RPM"
    }

    private func percentage(forRPM rpm: Double) -> Double {
        guard maxRPM > minRPM else {
            return 0
        }
        return max(0, min(100, (rpm - minRPM) / (maxRPM - minRPM) * 100))
    }

    private func rpmForCurrentPercentage() -> Int {
        let rpm = minRPM + (maxRPM - minRPM) * slider.doubleValue / 100
        let rounded = (rpm / 100).rounded() * 100
        let clamped = max(minRPM, min(maxRPM, rounded))
        return Int(clamped.rounded())
    }
}

let app = NSApplication.shared
let delegate = FanMenuApp()
app.delegate = delegate
app.run()
