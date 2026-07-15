import AppKit
import Darwin
import FanCore
import Foundation
import ServiceManagement

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
        case back
        case device
        case renderer
        case tiler
        case used
        case active
        case wired
        case compressed
        case inactive
        case download
        case upload
        case received
        case sent
        case usageDetails
        case applicationUsage
        case loading
        case noApplicationData
        case systemAndOther
        case fanSpeedControl
        case system
        case max
        case speed
        case launchAtLogin
        case loginItemRequiresApproval
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

    static func coreCount(_ count: Int) -> String {
        switch language {
        case .en:
            return "\(count)-core"
        case .zhHans:
            return "\(count) 核"
        case .zhHant:
            return "\(count) 核心"
        case .ja:
            return "\(count)コア"
        case .ko:
            return "\(count)코어"
        case .es:
            return "\(count) núcleos"
        case .fr:
            return "\(count) cœurs"
        case .de:
            return "\(count) Kerne"
        case .pt:
            return "\(count) núcleos"
        case .ru:
            return "\(count) ядер"
        }
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
            .back: "Back",
            .device: "Device",
            .renderer: "Renderer",
            .tiler: "Tiler",
            .used: "Used",
            .active: "Active",
            .wired: "Wired",
            .compressed: "Compressed",
            .inactive: "Inactive",
            .download: "Download",
            .upload: "Upload",
            .received: "Received",
            .sent: "Sent",
            .usageDetails: "Usage",
            .applicationUsage: "Apps",
            .loading: "Loading...",
            .noApplicationData: "No application data available",
            .systemAndOther: "System & Other",
            .fanSpeedControl: "Fan Speed Control",
            .system: "System",
            .max: "Max",
            .speed: "Current Speed",
            .launchAtLogin: "Launch at Login",
            .loginItemRequiresApproval: "Allow in System Settings",
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
            .back: "返回",
            .device: "设备",
            .renderer: "渲染器",
            .tiler: "铺砖器",
            .used: "已使用",
            .active: "活跃内存",
            .wired: "联动内存",
            .compressed: "压缩内存",
            .inactive: "非活跃内存",
            .download: "下载速度",
            .upload: "上传速度",
            .received: "已接收",
            .sent: "已发送",
            .usageDetails: "当前使用",
            .applicationUsage: "应用占用",
            .loading: "正在加载…",
            .noApplicationData: "暂无可用的应用占用数据",
            .systemAndOther: "系统与其他",
            .fanSpeedControl: "风扇转速控制",
            .system: "系统",
            .max: "最大",
            .speed: "当前转速",
            .launchAtLogin: "开机自启",
            .loginItemRequiresApproval: "请在系统设置中允许",
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
            .back: "返回",
            .device: "裝置",
            .renderer: "渲染器",
            .tiler: "鋪磚器",
            .used: "已使用",
            .active: "活躍記憶體",
            .wired: "聯動記憶體",
            .compressed: "壓縮記憶體",
            .inactive: "非活躍記憶體",
            .download: "下載速度",
            .upload: "上傳速度",
            .received: "已接收",
            .sent: "已傳送",
            .usageDetails: "目前使用",
            .applicationUsage: "App 佔用",
            .loading: "正在載入…",
            .noApplicationData: "暫無可用的 App 佔用資料",
            .systemAndOther: "系統與其他",
            .fanSpeedControl: "風扇轉速控制",
            .system: "系統",
            .max: "最大",
            .speed: "目前轉速",
            .launchAtLogin: "登入時啟動",
            .loginItemRequiresApproval: "請在系統設定中允許",
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
            .back: "戻る",
            .device: "デバイス",
            .renderer: "レンダラー",
            .tiler: "タイラー",
            .used: "使用中",
            .active: "アクティブ",
            .wired: "固定",
            .compressed: "圧縮",
            .inactive: "非アクティブ",
            .download: "ダウンロード",
            .upload: "アップロード",
            .received: "受信済み",
            .sent: "送信済み",
            .usageDetails: "現在の使用状況",
            .applicationUsage: "アプリ使用量",
            .loading: "読み込み中…",
            .noApplicationData: "アプリ使用量データがありません",
            .systemAndOther: "システムとその他",
            .fanSpeedControl: "ファン速度制御",
            .system: "システム",
            .max: "最大",
            .speed: "現在の回転数",
            .launchAtLogin: "ログイン時に起動",
            .loginItemRequiresApproval: "システム設定で許可してください",
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
            .back: "뒤로",
            .device: "기기",
            .renderer: "렌더러",
            .tiler: "타일러",
            .used: "사용됨",
            .active: "활성",
            .wired: "고정",
            .compressed: "압축됨",
            .inactive: "비활성",
            .download: "다운로드",
            .upload: "업로드",
            .received: "받음",
            .sent: "보냄",
            .usageDetails: "현재 사용량",
            .applicationUsage: "앱 사용량",
            .loading: "불러오는 중…",
            .noApplicationData: "사용 가능한 앱 데이터가 없습니다",
            .systemAndOther: "시스템 및 기타",
            .fanSpeedControl: "팬 속도 제어",
            .system: "시스템",
            .max: "최대",
            .speed: "현재 회전 속도",
            .launchAtLogin: "로그인 시 실행",
            .loginItemRequiresApproval: "시스템 설정에서 허용하세요",
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
            .back: "Atrás",
            .device: "Dispositivo",
            .renderer: "Renderizador",
            .tiler: "Mosaico",
            .used: "Usada",
            .active: "Activa",
            .wired: "Cableada",
            .compressed: "Comprimida",
            .inactive: "Inactiva",
            .download: "Descarga",
            .upload: "Subida",
            .received: "Recibido",
            .sent: "Enviado",
            .usageDetails: "Uso actual",
            .applicationUsage: "Aplicaciones",
            .loading: "Cargando…",
            .noApplicationData: "No hay datos de aplicaciones",
            .systemAndOther: "Sistema y otros",
            .fanSpeedControl: "Control de velocidad",
            .system: "Sistema",
            .max: "Max",
            .speed: "Velocidad actual",
            .launchAtLogin: "Abrir al iniciar sesión",
            .loginItemRequiresApproval: "Permitir en Ajustes del Sistema",
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
            .back: "Retour",
            .device: "Appareil",
            .renderer: "Moteur de rendu",
            .tiler: "Tuilage",
            .used: "Utilisée",
            .active: "Active",
            .wired: "Câblée",
            .compressed: "Compressée",
            .inactive: "Inactive",
            .download: "Téléchargement",
            .upload: "Envoi",
            .received: "Reçu",
            .sent: "Envoyé",
            .usageDetails: "Utilisation",
            .applicationUsage: "Applications",
            .loading: "Chargement…",
            .noApplicationData: "Aucune donnée d’application disponible",
            .systemAndOther: "Système et autres",
            .fanSpeedControl: "Controle de vitesse",
            .system: "Systeme",
            .max: "Max",
            .speed: "Vitesse actuelle",
            .launchAtLogin: "Ouvrir à la connexion",
            .loginItemRequiresApproval: "Autoriser dans Réglages Système",
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
            .back: "Zurück",
            .device: "Gerät",
            .renderer: "Renderer",
            .tiler: "Tiler",
            .used: "Verwendet",
            .active: "Aktiv",
            .wired: "Gebunden",
            .compressed: "Komprimiert",
            .inactive: "Inaktiv",
            .download: "Download",
            .upload: "Upload",
            .received: "Empfangen",
            .sent: "Gesendet",
            .usageDetails: "Aktuelle Nutzung",
            .applicationUsage: "Apps",
            .loading: "Wird geladen…",
            .noApplicationData: "Keine App-Nutzungsdaten verfügbar",
            .systemAndOther: "System und Sonstiges",
            .fanSpeedControl: "Luefterdrehzahl",
            .system: "System",
            .max: "Max",
            .speed: "Aktuelle Drehzahl",
            .launchAtLogin: "Bei der Anmeldung öffnen",
            .loginItemRequiresApproval: "In Systemeinstellungen erlauben",
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
            .back: "Voltar",
            .device: "Dispositivo",
            .renderer: "Renderizador",
            .tiler: "Mosaico",
            .used: "Usada",
            .active: "Ativa",
            .wired: "Vinculada",
            .compressed: "Comprimida",
            .inactive: "Inativa",
            .download: "Download",
            .upload: "Upload",
            .received: "Recebido",
            .sent: "Enviado",
            .usageDetails: "Uso atual",
            .applicationUsage: "Aplicativos",
            .loading: "Carregando…",
            .noApplicationData: "Nenhum dado de aplicativo disponível",
            .systemAndOther: "Sistema e outros",
            .fanSpeedControl: "Controle de velocidade",
            .system: "Sistema",
            .max: "Max",
            .speed: "Velocidade atual",
            .launchAtLogin: "Abrir ao iniciar sessão",
            .loginItemRequiresApproval: "Permitir nos Ajustes do Sistema",
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
            .back: "Назад",
            .device: "Устройство",
            .renderer: "Рендерер",
            .tiler: "Тайлер",
            .used: "Используется",
            .active: "Активная",
            .wired: "Связанная",
            .compressed: "Сжатая",
            .inactive: "Неактивная",
            .download: "Загрузка",
            .upload: "Отправка",
            .received: "Получено",
            .sent: "Отправлено",
            .usageDetails: "Текущее использование",
            .applicationUsage: "Приложения",
            .loading: "Загрузка…",
            .noApplicationData: "Нет данных об использовании приложений",
            .systemAndOther: "Система и прочее",
            .fanSpeedControl: "Скорость вентилятора",
            .system: "Система",
            .max: "Макс",
            .speed: "Текущая скорость",
            .launchAtLogin: "Открывать при входе",
            .loginItemRequiresApproval: "Разрешите в Системных настройках",
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

private enum OverviewDetailKind: Sendable {
    case cpu
    case gpu
    case memory
    case network
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
    private var currentOverviewView: SystemOverviewView?
    private weak var currentOverviewItem: NSMenuItem?
    private weak var currentOverviewDetailView: OverviewDetailView?
    private weak var currentFanPanelView: FanPanelView?
    private weak var currentLaunchAtLoginRow: BottomMenuActionRowView?

    func applicationDidFinishLaunching(_ notification: Notification) {
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
        currentOverviewDetailView?.stopUpdates()
        currentOverviewView = nil
        currentOverviewItem = nil
        currentOverviewDetailView = nil
        currentFanPanelView = nil
        currentLaunchAtLoginRow = nil

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
        addLaunchAtLoginItem(to: menu)
        addQuitItem(to: menu)
        statusItem.menu = menu
    }

    private func addQuitItem(to menu: NSMenu) {
        let row = BottomMenuActionRowView(
            title: L10n.text(.quit),
            accessory: .shortcut("⌘Q"),
            width: menuWidth,
            onAction: { [weak self] in self?.quit() }
        )
        let quitItem = addView(row, to: menu)
        quitItem.action = #selector(quit)
        quitItem.target = self
        quitItem.keyEquivalent = "q"
    }

    private func addLaunchAtLoginItem(to menu: NSMenu) {
        let service = SMAppService.mainApp
        var title = L10n.text(.launchAtLogin)
        if service.status == .requiresApproval {
            title += " — \(L10n.text(.loginItemRequiresApproval))"
        }

        let row = BottomMenuActionRowView(
            title: title,
            accessory: .checkmark(isVisible: service.status == .enabled),
            width: menuWidth,
            closesMenuOnAction: false,
            onAction: { [weak self] in self?.toggleLaunchAtLogin() }
        )
        currentLaunchAtLoginRow = row
        addView(row, to: menu)
    }

    private func updateLaunchAtLoginRow() {
        let service = SMAppService.mainApp
        var title = L10n.text(.launchAtLogin)
        if service.status == .requiresApproval {
            title += " — \(L10n.text(.loginItemRequiresApproval))"
        }
        currentLaunchAtLoginRow?.updateCheckmark(title: title, isVisible: service.status == .enabled)
    }

    private func updateOpenMenuViews() {
        if let latestSystem {
            currentOverviewView?.update(snapshot: latestSystem, temperatures: groupedTemperatureRows(latestTemperatures))
            currentOverviewDetailView?.update(snapshot: latestSystem)
        }
        currentFanPanelView?.update(fans: latestFans, pendingTargetRPM: activePendingFanTarget(), pendingMode: currentFanModeForDisplay())
        updateLaunchAtLoginRow()
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
        let view = SystemOverviewView(
            snapshot: snapshot,
            temperatures: temperatures,
            width: menuWidth,
            onOpenDetail: { [weak self] kind in self?.showOverviewDetail(kind) }
        )
        currentOverviewView = view
        currentOverviewItem = addView(view, to: menu)
    }

    private func showOverviewDetail(_ kind: OverviewDetailKind) {
        guard let menu = statusItem.menu,
              let item = currentOverviewItem,
              let snapshot = latestSystem else {
            return
        }

        DispatchQueue.main.async { [weak self, weak menu, weak item] in
            guard let self, let menu, let item else {
                return
            }
            let detailView = OverviewDetailView(
                kind: kind,
                snapshot: snapshot,
                width: self.menuWidth,
                onBack: { [weak self] in self?.hideOverviewDetail() }
            )
            self.currentOverviewDetailView = detailView
            item.view = detailView
            for menuItem in menu.items where menuItem !== item {
                menuItem.isHidden = true
            }
            detailView.animateEntrance(fromTrailingEdge: true)
        }
    }

    private func hideOverviewDetail() {
        guard let menu = statusItem.menu,
              let item = currentOverviewItem,
              let overviewView = currentOverviewView else {
            return
        }

        DispatchQueue.main.async { [weak self, weak menu, weak item, weak overviewView] in
            guard let self, let menu, let item, let overviewView else {
                return
            }
            self.currentOverviewDetailView?.stopUpdates()
            item.view = overviewView
            for menuItem in menu.items {
                menuItem.isHidden = false
            }
            self.currentOverviewDetailView = nil
            overviewView.animateEntrance(fromTrailingEdge: false)
        }
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

    @discardableResult
    private func addView(_ view: NSView, to menu: NSMenu) -> NSMenuItem {
        let item = NSMenuItem()
        item.view = view
        menu.addItem(item)
        return item
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
        guard needsAuthorization else {
            performHelperCommands(commands)
            return
        }

        prepareForAuthorization(commands)
    }

    private func prepareForAuthorization(_ commands: [String]) {
        // SecurityAgent can display its password dialog without keyboard focus
        // when it is launched directly from an accessory app's menu tracking loop.
        // End menu tracking, temporarily make MacBoard a regular foreground app,
        // and give AppKit a run-loop turn to complete activation first.
        statusItem.menu?.cancelTracking()
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }

            let previousActivationPolicy = NSApp.activationPolicy()
            if previousActivationPolicy != .regular {
                NSApp.setActivationPolicy(.regular)
            }

            if #available(macOS 14.0, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self else {
                    return
                }

                self.performHelperCommands(commands)
                if previousActivationPolicy != .regular {
                    NSApp.setActivationPolicy(previousActivationPolicy)
                }
            }
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

    private func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            switch service.status {
            case .enabled:
                try service.unregister()
            case .requiresApproval:
                SMAppService.openSystemSettingsLoginItems()
            case .notRegistered, .notFound:
                try service.register()
                if service.status == .requiresApproval {
                    SMAppService.openSystemSettingsLoginItems()
                }
            @unknown default:
                try service.register()
            }
        } catch {
            if service.status == .requiresApproval {
                SMAppService.openSystemSettingsLoginItems()
            } else {
                let alert = NSAlert(error: error)
                alert.messageText = L10n.text(.launchAtLogin)
                alert.runModal()
            }
        }
        updateLaunchAtLoginRow()
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

    init(
        snapshot: SystemSnapshot,
        temperatures: [(name: String, celsius: Double)],
        width: Int,
        onOpenDetail: @escaping (OverviewDetailKind) -> Void
    ) {
        super.init(frame: NSRect(x: 0, y: 0, width: CGFloat(width), height: Self.preferredHeight(for: snapshot)))
        setup(snapshot: snapshot, temperatures: temperatures, width: width, onOpenDetail: onOpenDetail)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setup(
        snapshot: SystemSnapshot,
        temperatures: [(name: String, celsius: Double)],
        width: Int,
        onOpenDetail: @escaping (OverviewDetailKind) -> Void
    ) {
        let temp = temperatureMap(temperatures)
        let header = SectionHeaderView(
            title: L10n.text(.overview),
            systemImage: "gauge.with.dots.needle.67percent",
            trailingText: snapshot.processorModel,
            width: width
        )
        header.frame = NSRect(x: 0, y: 10, width: width, height: 30)
        addSubview(header)

        let cpu = snapshot.cpuLoad.map { cpuLoad in
            MetricTileView(
                title: "CPU",
                value: "\(Int((cpuLoad * 100).rounded()))%",
                detail: hardwareDetail(coreCount: snapshot.cpuCoreCount, temperature: temp["CPU"]),
                progress: cpuLoad,
                onTitleClick: { onOpenDetail(.cpu) }
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
                progress: memoryPercent,
                onTitleClick: { onOpenDetail(.memory) }
            )
        }
        let gpu = snapshot.gpuLoad.map {
            MetricTileView(
                title: "GPU",
                value: "\(Int(($0 * 100).rounded()))%",
                detail: hardwareDetail(coreCount: snapshot.gpuCoreCount, temperature: temp["GPU"]),
                progress: $0,
                onTitleClick: { onOpenDetail(.gpu) }
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
                progress: networkProgress(down: down, up: up),
                onTitleClick: { onOpenDetail(.network) }
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

    func animateEntrance(fromTrailingEdge: Bool) {
        wantsLayer = true
        guard let layer else {
            return
        }
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.toValue = 1
        fade.duration = 0.2
        fade.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let slide = CABasicAnimation(keyPath: "transform.translation.x")
        slide.fromValue = fromTrailingEdge ? 18 : -18
        slide.toValue = 0
        slide.duration = 0.24
        slide.timingFunction = CAMediaTimingFunction(name: .easeOut)

        layer.add(fade, forKey: "overviewFadeIn")
        layer.add(slide, forKey: "overviewSlideIn")
    }

    func update(snapshot: SystemSnapshot, temperatures: [(name: String, celsius: Double)]) {
        let temp = temperatureMap(temperatures)
        if let cpuLoad = snapshot.cpuLoad {
            cpuTile?.isHidden = false
            cpuTile?.update(
                value: "\(Int((cpuLoad * 100).rounded()))%",
                detail: hardwareDetail(coreCount: snapshot.cpuCoreCount, temperature: temp["CPU"]),
                progress: cpuLoad
            )
        } else {
            cpuTile?.isHidden = true
        }
        if let gpuLoad = snapshot.gpuLoad {
            gpuTile?.isHidden = false
            gpuTile?.update(
                value: "\(Int((gpuLoad * 100).rounded()))%",
                detail: hardwareDetail(coreCount: snapshot.gpuCoreCount, temperature: temp["GPU"]),
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

    private func hardwareDetail(coreCount: Int?, temperature: Double?) -> String? {
        let detail = joinedDetail([
            coreCount.map(L10n.coreCount),
            temperature.map { "\(Int($0.rounded()))℃" }
        ])
        return detail.isEmpty ? nil : detail
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

private struct DetailMetricModel {
    let id: String
    let title: String
    let value: String
    let progress: Double?
}

@MainActor
private final class OverviewDetailView: NSView {
    private let kind: OverviewDetailKind
    private let width: Int
    private let rowsContainer = FlippedView()
    private let scrollView = NSScrollView()
    private let pageControl = NSSegmentedControl(
        labels: [L10n.text(.applicationUsage), L10n.text(.usageDetails)],
        trackingMode: .selectOne,
        target: nil,
        action: nil
    )
    private var rowViews: [DetailMetricRowView] = []
    private var latestSnapshot: SystemSnapshot
    private var applicationRefreshTimer: Timer?
    private var isLoadingApplications = false
    private var applicationRequestID = 0

    private static let visibleRowCount = 8

    override var isFlipped: Bool {
        true
    }

    init(kind: OverviewDetailKind, snapshot: SystemSnapshot, width: Int, onBack: @escaping () -> Void) {
        self.kind = kind
        self.width = width
        latestSnapshot = snapshot
        let rows = [DetailMetricModel(id: "loading", title: L10n.text(.loading), value: "", progress: nil)]
        super.init(frame: NSRect(
            x: 0,
            y: 0,
            width: width,
            height: 88 + Self.visibleRowCount * 30 + 12
        ))
        wantsLayer = true

        let header = DetailPageHeaderView(title: Self.title(for: kind), width: width, onBack: onBack)
        header.frame = NSRect(x: 0, y: 8, width: width, height: 38)
        addSubview(header)

        pageControl.frame = NSRect(x: 40, y: 50, width: width - 80, height: 28)
        pageControl.segmentStyle = .rounded
        pageControl.font = .systemFont(ofSize: 11, weight: .medium)
        pageControl.setWidth(CGFloat(width - 80) / 2, forSegment: 0)
        pageControl.setWidth(CGFloat(width - 80) / 2, forSegment: 1)
        pageControl.selectedSegment = 0
        pageControl.target = self
        pageControl.action = #selector(pageChanged(_:))
        addSubview(pageControl)

        scrollView.frame = NSRect(x: 0, y: 84, width: width, height: Self.visibleRowCount * 30 + 6)
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = rows.count > Self.visibleRowCount
        scrollView.autohidesScrollers = true
        rowsContainer.frame = NSRect(x: 0, y: 0, width: width, height: max(1, rows.count) * 30)
        scrollView.documentView = rowsContainer
        addSubview(scrollView)

        apply(rows)
        startApplicationRefresh()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func update(snapshot: SystemSnapshot) {
        latestSnapshot = snapshot
        if pageControl.selectedSegment == 1 {
            apply(Self.metrics(for: kind, snapshot: snapshot))
        }
    }

    func stopUpdates() {
        applicationRequestID += 1
        isLoadingApplications = false
        stopApplicationRefresh()
    }

    func animateEntrance(fromTrailingEdge: Bool) {
        guard let layer else {
            return
        }
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.toValue = 1
        fade.duration = 0.2
        fade.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let slide = CABasicAnimation(keyPath: "transform.translation.x")
        slide.fromValue = fromTrailingEdge ? 18 : -18
        slide.toValue = 0
        slide.duration = 0.24
        slide.timingFunction = CAMediaTimingFunction(name: .easeOut)

        layer.add(fade, forKey: "detailFadeIn")
        layer.add(slide, forKey: "detailSlideIn")
    }

    private func apply(_ rows: [DetailMetricModel]) {
        scrollView.hasVerticalScroller = rows.count > Self.visibleRowCount
        let needsRebuild = rowViews.count != rows.count || zip(rowViews, rows).contains { $0.metricID != $1.id }
        if needsRebuild {
            rowViews.forEach { $0.removeFromSuperview() }
            rowViews = rows.enumerated().map { index, model in
                let row = DetailMetricRowView(model: model)
                row.frame = NSRect(x: 0, y: index * 30, width: width, height: 30)
                rowsContainer.addSubview(row)
                return row
            }
            rowsContainer.frame.size.height = CGFloat(max(1, rows.count) * 30)
        } else {
            zip(rowViews, rows).forEach { $0.update(model: $1) }
        }
    }

    @objc private func pageChanged(_ sender: NSSegmentedControl) {
        applicationRequestID += 1
        isLoadingApplications = false
        if sender.selectedSegment == 1 {
            stopApplicationRefresh()
            apply(Self.metrics(for: kind, snapshot: latestSnapshot))
            animateRows(fromTrailingEdge: true)
        } else {
            apply([DetailMetricModel(id: "loading", title: L10n.text(.loading), value: "", progress: nil)])
            animateRows(fromTrailingEdge: false)
            startApplicationRefresh()
        }
    }

    private func startApplicationRefresh() {
        stopApplicationRefresh()
        refreshApplicationUsage()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshApplicationUsage()
            }
        }
        timer.tolerance = 0.2
        RunLoop.main.add(timer, forMode: .common)
        applicationRefreshTimer = timer
    }

    private func stopApplicationRefresh() {
        applicationRefreshTimer?.invalidate()
        applicationRefreshTimer = nil
    }

    private func refreshApplicationUsage() {
        guard pageControl.selectedSegment == 0, !isLoadingApplications else {
            return
        }
        isLoadingApplications = true
        applicationRequestID += 1
        let requestID = applicationRequestID
        let metric = applicationMetric

        Task.detached(priority: .utility) {
            let sample = ApplicationUsageMonitor.sample(metric)
            await MainActor.run { [weak self] in
                guard let self, self.applicationRequestID == requestID else {
                    return
                }
                self.isLoadingApplications = false
                guard self.pageControl.selectedSegment == 0 else {
                    return
                }
                guard sample.isReady else {
                    self.apply([DetailMetricModel(
                        id: "loading",
                        title: L10n.text(.loading),
                        value: "",
                        progress: nil
                    )])
                    return
                }
                let rows = self.applicationMetrics(sample)
                self.apply(rows.isEmpty ? [DetailMetricModel(
                    id: "no-application-data",
                    title: L10n.text(.noApplicationData),
                    value: "",
                    progress: nil
                )] : rows)
            }
        }
    }

    private var applicationMetric: ApplicationUsageMetric {
        switch kind {
        case .cpu:
            return .cpu
        case .gpu:
            return .gpu
        case .memory:
            return .memory
        case .network:
            return .network
        }
    }

    private func applicationMetrics(_ sample: ApplicationUsageSample) -> [DetailMetricModel] {
        var rows = sample.entries.map { entry in
            let value: String
            let progress: Double?
            switch kind {
            case .cpu:
                value = Self.applicationPercent(entry.value, capsAt100Percent: true)
                progress = min(1, max(0, entry.value))
            case .gpu:
                value = Self.applicationPercent(entry.value, capsAt100Percent: true)
                progress = min(1, max(0, entry.value))
            case .memory:
                value = formatBytes(UInt64(max(0, entry.value)))
                progress = latestSnapshot.memoryTotal.flatMap { total in
                    total > 0 ? min(1, entry.value / Double(total)) : nil
                }
            case .network:
                let up = entry.auxiliaryValue ?? 0
                value = "↓ \(formatRate(entry.value))  ↑ \(formatRate(up))"
                progress = min(1, max(0, (entry.value + up) / (10 * 1024 * 1024)))
            }
            return DetailMetricModel(
                id: "application-\(entry.id)",
                title: entry.name,
                value: value,
                progress: progress
            )
        }

        if kind == .cpu, let totalValue = sample.totalValue {
            let attributedValue = sample.entries.reduce(0) { $0 + $1.value }
            let unattributedValue = max(0, totalValue - attributedValue)
            if unattributedValue > 0.0001 {
                rows.append(DetailMetricModel(
                    id: "application-system-and-other",
                    title: L10n.text(.systemAndOther),
                    value: Self.applicationPercent(unattributedValue, capsAt100Percent: true),
                    progress: min(1, unattributedValue)
                ))
                rows.sort { ($0.progress ?? 0) > ($1.progress ?? 0) }
            }
        }
        return rows
    }

    private func animateRows(fromTrailingEdge: Bool) {
        rowsContainer.wantsLayer = true
        guard let layer = rowsContainer.layer else {
            return
        }
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.toValue = 1
        fade.duration = 0.16
        let slide = CABasicAnimation(keyPath: "transform.translation.x")
        slide.fromValue = fromTrailingEdge ? 12 : -12
        slide.toValue = 0
        slide.duration = 0.2
        slide.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(fade, forKey: "pageFadeIn")
        layer.add(slide, forKey: "pageSlideIn")
    }

    private static func title(for kind: OverviewDetailKind) -> String {
        switch kind {
        case .cpu:
            return "CPU"
        case .gpu:
            return "GPU"
        case .memory:
            return L10n.text(.memory)
        case .network:
            return L10n.text(.network)
        }
    }

    private static func metrics(for kind: OverviewDetailKind, snapshot: SystemSnapshot) -> [DetailMetricModel] {
        switch kind {
        case .cpu:
            return (snapshot.cpuCoreLoads ?? []).enumerated().map { index, load in
                DetailMetricModel(
                    id: "cpu-\(index)",
                    title: "CPU \(index + 1)",
                    value: percent(load),
                    progress: load
                )
            }
        case .gpu:
            return compactMetrics([
                metric(id: "gpu-device", title: L10n.text(.device), progress: snapshot.gpuDeviceLoad),
                metric(id: "gpu-renderer", title: L10n.text(.renderer), progress: snapshot.gpuRendererLoad),
                metric(id: "gpu-tiler", title: L10n.text(.tiler), progress: snapshot.gpuTilerLoad)
            ])
        case .memory:
            guard let total = snapshot.memoryTotal, total > 0 else {
                return []
            }
            return compactMetrics([
                byteMetric(id: "memory-used", title: L10n.text(.used), bytes: snapshot.memoryUsed, total: total),
                byteMetric(id: "memory-active", title: L10n.text(.active), bytes: snapshot.memoryActive, total: total),
                byteMetric(id: "memory-wired", title: L10n.text(.wired), bytes: snapshot.memoryWired, total: total),
                byteMetric(id: "memory-compressed", title: L10n.text(.compressed), bytes: snapshot.memoryCompressed, total: total),
                byteMetric(id: "memory-inactive", title: L10n.text(.inactive), bytes: snapshot.memoryInactive, total: total)
            ])
        case .network:
            return compactMetrics([
                rateMetric(id: "network-download", title: L10n.text(.download), rate: snapshot.networkDownBytesPerSecond),
                rateMetric(id: "network-upload", title: L10n.text(.upload), rate: snapshot.networkUpBytesPerSecond),
                totalMetric(id: "network-received", title: L10n.text(.received), bytes: snapshot.networkReceivedBytes),
                totalMetric(id: "network-sent", title: L10n.text(.sent), bytes: snapshot.networkSentBytes)
            ])
        }
    }

    private static func compactMetrics(_ values: [DetailMetricModel?]) -> [DetailMetricModel] {
        values.compactMap { $0 }
    }

    private static func metric(id: String, title: String, progress: Double?) -> DetailMetricModel? {
        progress.map { DetailMetricModel(id: id, title: title, value: percent($0), progress: $0) }
    }

    private static func byteMetric(id: String, title: String, bytes: UInt64?, total: UInt64) -> DetailMetricModel? {
        bytes.map {
            DetailMetricModel(
                id: id,
                title: title,
                value: formatBytes($0),
                progress: min(1, Double($0) / Double(total))
            )
        }
    }

    private static func rateMetric(id: String, title: String, rate: Double?) -> DetailMetricModel? {
        rate.map {
            DetailMetricModel(
                id: id,
                title: title,
                value: formatRate($0),
                progress: min(1, max(0, $0 / (10 * 1024 * 1024)))
            )
        }
    }

    private static func totalMetric(id: String, title: String, bytes: UInt64?) -> DetailMetricModel? {
        bytes.map { DetailMetricModel(id: id, title: title, value: formatBytes($0), progress: nil) }
    }

    private static func percent(_ value: Double) -> String {
        "\(Int((min(1, max(0, value)) * 100).rounded()))%"
    }

    private static func applicationPercent(_ value: Double, capsAt100Percent: Bool) -> String {
        let rawPercentage = max(0, value * 100)
        let percentage = capsAt100Percent ? min(100, rawPercentage) : rawPercentage
        if percentage >= 10 {
            return String(format: "%.0f%%", percentage)
        }
        if percentage >= 1 {
            return String(format: "%.1f%%", percentage)
        }
        if percentage > 0 {
            return String(format: "%.2f%%", percentage)
        }
        return "0%"
    }
}

@MainActor
private final class DetailPageHeaderView: NSView {
    private let onBack: () -> Void

    init(title: String, width: Int, onBack: @escaping () -> Void) {
        self.onBack = onBack
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 38))

        let backButton = NSButton(title: L10n.text(.back), target: self, action: #selector(backPressed))
        backButton.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: L10n.text(.back))
        backButton.imagePosition = .imageLeading
        backButton.bezelStyle = .inline
        backButton.isBordered = false
        backButton.font = .systemFont(ofSize: 12, weight: .medium)
        backButton.contentTintColor = .secondaryLabelColor
        backButton.frame = NSRect(x: 14, y: 6, width: 74, height: 26)
        addSubview(backButton)

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .labelColor
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 88, y: 7, width: width - 176, height: 24)
        addSubview(titleLabel)
    }

    required init?(coder: NSCoder) {
        nil
    }

    @objc private func backPressed() {
        onBack()
    }
}

@MainActor
private final class DetailMetricRowView: NSView {
    let metricID: String
    private var title: String
    private var value: String
    private var progress: Double?

    override var isFlipped: Bool {
        true
    }

    init(model: DetailMetricModel) {
        metricID = model.id
        title = model.title
        value = model.value
        progress = model.progress
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func update(model: DetailMetricModel) {
        title = model.title
        value = model.value
        progress = model.progress
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let titleParagraph = NSMutableParagraphStyle()
        titleParagraph.lineBreakMode = .byTruncatingTail
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: NSColor.labelColor.withAlphaComponent(0.9),
            .paragraphStyle: titleParagraph
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor.secondaryLabelColor
        ]
        let valueSize = value.size(withAttributes: valueAttributes)
        let titleWidth = max(40, bounds.width - 52 - valueSize.width)
        title.draw(
            in: NSRect(x: 20, y: 1, width: titleWidth, height: 17),
            withAttributes: titleAttributes
        )
        value.draw(at: NSPoint(x: bounds.width - 20 - valueSize.width, y: 1), withAttributes: valueAttributes)

        guard let progress else {
            return
        }
        let track = NSRect(x: 20, y: 22, width: bounds.width - 40, height: 3)
        NSColor.separatorColor.withAlphaComponent(0.4).setFill()
        NSBezierPath(roundedRect: track, xRadius: 1.5, yRadius: 1.5).fill()
        let fill = NSRect(x: track.minX, y: track.minY, width: track.width * min(1, max(0, progress)), height: track.height)
        NSColor.controlAccentColor.withAlphaComponent(0.9).setFill()
        NSBezierPath(roundedRect: fill, xRadius: 1.5, yRadius: 1.5).fill()
    }
}

private final class FlippedView: NSView {
    override var isFlipped: Bool {
        true
    }
}

@MainActor
private final class MetricTileView: NSView {
    private let title: String
    private let onTitleClick: (() -> Void)?
    private var value: String
    private var detail: String?
    private var progress: Double
    private var hoverTrackingArea: NSTrackingArea?
    private var isTitleHovered = false

    override var isFlipped: Bool {
        true
    }

    init(
        title: String,
        value: String,
        detail: String? = nil,
        progress: Double,
        onTitleClick: (() -> Void)? = nil
    ) {
        self.title = title
        self.onTitleClick = onTitleClick
        self.value = value
        self.detail = detail
        self.progress = max(0, min(1, progress))
        super.init(frame: .zero)
        wantsLayer = true
        if onTitleClick != nil {
            setAccessibilityRole(.button)
            setAccessibilityLabel(title)
        }
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

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let hoverTrackingArea {
            removeTrackingArea(hoverTrackingArea)
        }
        guard onTitleClick != nil else {
            hoverTrackingArea = nil
            return
        }
        let trackingArea = NSTrackingArea(
            rect: titleHitRect,
            options: [.activeAlways, .mouseEnteredAndExited, .cursorUpdate],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        hoverTrackingArea = trackingArea
    }

    override func mouseEntered(with event: NSEvent) {
        isTitleHovered = true
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        isTitleHovered = false
        needsDisplay = true
    }

    override func cursorUpdate(with event: NSEvent) {
        onTitleClick == nil ? NSCursor.arrow.set() : NSCursor.pointingHand.set()
    }

    override func mouseDown(with event: NSEvent) {
        guard let onTitleClick,
              titleHitRect.contains(convert(event.locationInWindow, from: nil)) else {
            super.mouseDown(with: event)
            return
        }
        onTitleClick()
    }

    private var titleHitRect: NSRect {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        let width = title.size(withAttributes: attributes).width + (onTitleClick == nil ? 8 : 24)
        return NSRect(x: 0, y: 0, width: width, height: 20)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: isTitleHovered ? NSColor.controlAccentColor : NSColor.labelColor.withAlphaComponent(0.88)
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold),
            .foregroundColor: NSColor.labelColor
        ]
        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: NSColor.secondaryLabelColor
        ]

        let titleY: CGFloat = onTitleClick == nil ? 0 : 1
        title.draw(at: NSPoint(x: 0, y: titleY), withAttributes: titleAttributes)
        if onTitleClick != nil {
            let titleSize = title.size(withAttributes: titleAttributes)
            let disclosureAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 15, weight: .semibold),
                .foregroundColor: isTitleHovered ? NSColor.controlAccentColor : NSColor.secondaryLabelColor
            ]
            let disclosureSize = "›".size(withAttributes: disclosureAttributes)
            let disclosureY = (titleSize.height - disclosureSize.height) / 2
            "›".draw(at: NSPoint(x: titleSize.width + 5, y: disclosureY), withAttributes: disclosureAttributes)
        }
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
    init(title: String, systemImage: String, trailingText: String? = nil, width: Int) {
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

        var constraints = [
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]

        if let trailingText, !trailingText.isEmpty {
            let trailingLabel = NSTextField(labelWithString: trailingText)
            trailingLabel.font = .systemFont(ofSize: 10, weight: .medium)
            trailingLabel.textColor = .secondaryLabelColor
            trailingLabel.alignment = .right
            trailingLabel.lineBreakMode = .byTruncatingMiddle
            trailingLabel.translatesAutoresizingMaskIntoConstraints = false
            trailingLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            addSubview(trailingLabel)

            constraints.append(contentsOf: [
                label.trailingAnchor.constraint(lessThanOrEqualTo: trailingLabel.leadingAnchor, constant: -8),
                trailingLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                trailingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
                trailingLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150)
            ])
        } else {
            constraints.append(label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -18))
        }

        NSLayoutConstraint.activate(constraints)
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
private final class BottomMenuActionRowView: NSView {
    enum Accessory {
        case checkmark(isVisible: Bool)
        case shortcut(String)
    }

    private let onAction: () -> Void
    private let closesMenuOnAction: Bool
    private let titleLabel = NSTextField(labelWithString: "")
    private let checkmarkView = NSImageView()
    private let shortcutLabel = NSTextField(labelWithString: "")
    private var hoverTrackingArea: NSTrackingArea?
    private var isHovered = false

    override var isFlipped: Bool {
        true
    }

    init(
        title: String,
        accessory: Accessory,
        width: Int,
        closesMenuOnAction: Bool = true,
        onAction: @escaping () -> Void
    ) {
        self.onAction = onAction
        self.closesMenuOnAction = closesMenuOnAction
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 28))

        titleLabel.stringValue = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.frame = NSRect(x: 20, y: 4, width: width - 64, height: 20)
        addSubview(titleLabel)

        checkmarkView.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: nil)
        checkmarkView.contentTintColor = .labelColor
        checkmarkView.imageScaling = .scaleProportionallyDown
        checkmarkView.frame = NSRect(x: width - 36, y: 6, width: 16, height: 16)
        addSubview(checkmarkView)

        shortcutLabel.font = .systemFont(ofSize: 13, weight: .regular)
        shortcutLabel.textColor = .secondaryLabelColor
        shortcutLabel.alignment = .right
        shortcutLabel.frame = NSRect(x: width - 64, y: 4, width: 44, height: 20)
        addSubview(shortcutLabel)

        switch accessory {
        case .checkmark(let isVisible):
            titleLabel.frame.size.width = CGFloat(width - 64)
            checkmarkView.isHidden = !isVisible
            shortcutLabel.isHidden = true
            setAccessibilityRole(.checkBox)
            setAccessibilityValue(isVisible)
        case .shortcut(let shortcut):
            titleLabel.frame.size.width = CGFloat(width - 92)
            checkmarkView.isHidden = true
            shortcutLabel.stringValue = shortcut
            setAccessibilityRole(.button)
        }
        setAccessibilityLabel(title)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func updateCheckmark(title: String, isVisible: Bool) {
        titleLabel.stringValue = title
        checkmarkView.isHidden = !isVisible
        setAccessibilityLabel(title)
        setAccessibilityValue(isVisible)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let hoverTrackingArea {
            removeTrackingArea(hoverTrackingArea)
        }
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        hoverTrackingArea = trackingArea
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        titleLabel.textColor = .alternateSelectedControlTextColor
        checkmarkView.contentTintColor = .alternateSelectedControlTextColor
        shortcutLabel.textColor = .alternateSelectedControlTextColor
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        titleLabel.textColor = .labelColor
        checkmarkView.contentTintColor = .labelColor
        shortcutLabel.textColor = .secondaryLabelColor
        needsDisplay = true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        bounds.contains(point) ? self : nil
    }

    override func mouseDown(with event: NSEvent) {
        guard bounds.contains(convert(event.locationInWindow, from: nil)) else {
            return
        }
        if closesMenuOnAction {
            enclosingMenuItem?.menu?.cancelTracking()
            DispatchQueue.main.async { [onAction] in
                onAction()
            }
        } else {
            onAction()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard isHovered else {
            return
        }
        NSColor.selectedContentBackgroundColor.setFill()
        bounds.fill()
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
app.setActivationPolicy(.accessory)
let delegate = FanMenuApp()
app.delegate = delegate
app.run()
