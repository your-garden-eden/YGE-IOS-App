// DATEI: LogLevel.swift
// PFAD: Services/Logging/LogLevel.swift
// ZWECK: Definiert die Klassifizierungsstufen für Protokollnachrichten.

import Foundation

/// Definiert den Schweregrad einer Protokollnachricht, um die Wichtigkeit und den Kontext
/// einer Meldung klar zu kennzeichnen.
public enum LogLevel: String {
    /// Detaillierte Informationen für Entwickler zur Fehlersuche. (z.B. Variablenzustände, Funktionsaufrufe)
    case debug
    
    /// Informative Nachrichten über den normalen App-Ablauf. (z.B. "Benutzer hat sich eingeloggt", "Ansicht erschienen")
    case info
    
    /// Bemerkenswerte Ereignisse, die aber keinen Fehler darstellen. (z.B. "API-Antwort war leer")
    case notice
    
    /// Weist auf potenzielle Probleme hin, die den App-Ablauf nicht sofort stören. (z.B. eine veraltete API wird verwendet)
    case warning
    
    /// Ein Laufzeitfehler, der erfolgreich abgefangen und behandelt wurde. (z.B. ein fehlgeschlagener API-Aufruf)
    case error
    
    /// Ein kritischer, nicht behebbarer Fehler, der zum sofortigen Absturz der App führt oder führen sollte.
    case fatal
    
    /// Stellt ein visuelles Emoji-Icon für jeden Loglevel bereit, um die Lesbarkeit in der Konsole zu verbessern.
    var icon: String {
        switch self {
        case .debug:   return "🔬" // Mikroskop: Für detaillierte Analyse
        case .info:    return "ℹ️" // Information: Für allgemeine Hinweise
        case .notice:  return "📝" // Notiz: Für bemerkenswerte Ereignisse
        case .warning: return "⚠️" // Warnung: Für potenzielle Gefahren
        case .error:   return "🔴" // Roter Punkt: Für abgefangene Fehler
        case .fatal:   return "💥" // Explosion: Für kritische, fatale Fehler
        }
    }
}
