//
//  AffirmationExpansionGenerator.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import Foundation

enum AffirmationExpansionGenerator {
    static func expand(affirmation: String, language: AffirmationLanguage) -> String {
        let trimmed = affirmation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return fallback(for: language) }

        let keyword = extractKeyword(from: trimmed, language: language)
        let template = template(for: language, keyword: keyword)
        return ensurePunctuation(template)
    }

    private static func extractKeyword(from text: String, language: AffirmationLanguage) -> String? {
        let lowered = text.lowercased()

        let candidates: [String]
        switch language {
        case .english:
            candidates = ["calm", "peace", "strength", "growth", "clarity", "focus", "confidence", "patience", "joy", "hope", "balance"]
        case .spanish:
            candidates = ["calma", "paz", "fuerza", "crecimiento", "claridad", "enfoque", "confianza", "paciencia", "alegría", "esperanza", "equilibrio"]
        }

        return candidates.first { lowered.contains($0) }
    }

    private static func template(for language: AffirmationLanguage, keyword: String?) -> String {
        switch language {
        case .english:
            if let keyword {
                return englishKeywordTemplates.randomElement()?
                    .replacingOccurrences(of: "{keyword}", with: keyword)
                    ?? "Let \(keyword) guide your next small step. You are allowed to move gently and still move forward."
            }
            return englishTemplates.randomElement()
                ?? "Give yourself a steady breath and a kind pace. Even small steps are meaningful progress."
        case .spanish:
            if let keyword {
                return spanishKeywordTemplates.randomElement()?
                    .replacingOccurrences(of: "{keyword}", with: keyword)
                    ?? "Deja que la \(keyword) guíe tu siguiente pequeño paso. Puedes avanzar con suavidad y seguir avanzando."
            }
            return spanishTemplates.randomElement()
                ?? "Regálate una respiración tranquila y un ritmo amable. Incluso los pasos pequeños son progreso."
        }
    }

    private static func fallback(for language: AffirmationLanguage) -> String {
        switch language {
        case .english:
            return "Breathe in, soften your shoulders, and keep going with care."
        case .spanish:
            return "Respira, suelta los hombros y sigue con cuidado."
        }
    }

    private static func ensurePunctuation(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let last = trimmed.last else { return trimmed }
        if ".!?".contains(last) { return trimmed }
        return trimmed + "."
    }

    private static let englishTemplates: [String] = [
        "Give yourself a steady breath and a kind pace. Even small steps are meaningful progress.",
        "Today, move with patience and curiosity. You do not have to rush to be enough.",
        "Let this moment be gentle. You can reset and begin again.",
        "Your effort counts, even in quiet ways. Keep showing up for yourself.",
        "Choose one calm breath and one clear intention. That is enough for now.",
        "You are allowed to move slowly and still move forward. Trust your rhythm.",
        "Meet yourself with kindness and the day will soften around you.",
        "Progress can be soft and steady. You are doing more than you see.",
        "Hold the thought that you are safe to grow. Let it guide your choices.",
        "Focus on what you can do next, not everything at once. That is real strength.",
        "Let today be simple and supportive. You can begin again at any moment.",
        "You do not need perfect conditions to take a peaceful step.",
        "Give yourself permission to breathe, then continue with care.",
        "Small choices add up. You are building something good.",
        "Let the next action be kind to your body and your mind.",
        "You can be gentle and decisive at the same time.",
        "Trust the quiet momentum you are creating today.",
        "Allow space for calm. It helps you hear what matters.",
        "You are allowed to pause. Pausing is also progress.",
        "Keep your focus on one supportive thought and carry it forward.",
        "Let today be guided by steadiness, not pressure.",
        "You are learning to trust yourself. That is powerful.",
        "Your pace is valid. Your path is yours.",
        "Choose a soft yes to yourself and move from there.",
        "Keep your mind open and your shoulders relaxed. You are safe here.",
        "You can meet this day with a calm heart and clear eyes.",
        "Even a gentle effort can change the direction of your day.",
        "You are doing your best with what you have. That is enough.",
        "Offer yourself a little compassion and keep going.",
        "Let your breath remind you that you are here and capable.",
        "There is room for ease. You do not have to carry everything at once.",
        "Trust that steady steps create lasting change.",
        "Choose clarity over urgency. You can move with intention.",
        "Your inner voice can be soft and still be strong.",
        "Let this affirmation settle in and guide your next step."
    ]

    private static let spanishTemplates: [String] = [
        "Regálate una respiración tranquila y un ritmo amable. Incluso los pasos pequeños son progreso.",
        "Hoy avanza con paciencia y curiosidad. No necesitas prisa para ser suficiente.",
        "Que este momento sea suave. Puedes reiniciar y comenzar de nuevo.",
        "Tu esfuerzo cuenta, incluso en lo silencioso. Sigue presente para ti.",
        "Elige una respiración calma y una intención clara. Eso basta por ahora.",
        "Puedes avanzar despacio y seguir avanzando. Confía en tu ritmo.",
        "Trátate con amabilidad y el día se volverá más ligero.",
        "El progreso puede ser suave y constante. Estás haciendo más de lo que ves.",
        "Mantén la idea de que puedes crecer con seguridad. Déjala guiar tus decisiones.",
        "Enfócate en el siguiente paso, no en todo a la vez. Esa es fuerza real.",
        "Que hoy sea simple y amable. Puedes empezar de nuevo en cualquier momento.",
        "No necesitas condiciones perfectas para dar un paso en paz.",
        "Permítete respirar y luego continúa con cuidado.",
        "Las pequeñas decisiones suman. Estás construyendo algo bueno.",
        "Haz que tu próximo paso sea amable con tu cuerpo y tu mente.",
        "Puedes ser suave y decidido a la vez.",
        "Confía en el impulso tranquilo que creas hoy.",
        "Deja espacio para la calma. Te ayuda a escuchar lo importante.",
        "Puedes pausar. Pausar también es avanzar.",
        "Sostén un pensamiento de apoyo y llévalo contigo.",
        "Que hoy te guíe la constancia, no la presión.",
        "Estás aprendiendo a confiar en ti. Eso es poderoso.",
        "Tu ritmo es válido. Tu camino es tuyo.",
        "Elige un sí suave hacia ti y avanza desde ahí.",
        "Mantén la mente abierta y los hombros relajados. Estás a salvo aquí.",
        "Puedes vivir este día con un corazón en calma y mirada clara.",
        "Incluso un esfuerzo suave puede cambiar tu día.",
        "Haces lo mejor que puedes con lo que tienes. Eso basta.",
        "Date un poco de compasión y sigue adelante.",
        "Deja que tu respiración te recuerde que estás aquí y puedes.",
        "Hay espacio para la calma. No tienes que llevarlo todo a la vez.",
        "Confía en que los pasos constantes crean cambios duraderos.",
        "Elige claridad antes que urgencia. Puedes avanzar con intención.",
        "Tu voz interior puede ser suave y aun así fuerte.",
        "Deja que esta afirmación se asiente y guíe tu siguiente paso."
    ]

    private static let englishKeywordTemplates: [String] = [
        "Let {keyword} lead your next breath. You are allowed to move softly and still move forward.",
        "Hold {keyword} close for a moment. It can steady your next step.",
        "Choose {keyword} today and let it shape your pace.",
        "When you center {keyword}, the rest becomes clearer. Take one calm step.",
        "Let {keyword} be your anchor. You can move with ease from here.",
        "Keep {keyword} in mind as you move through the day. It will guide you.",
        "Allow {keyword} to soften your path. You are doing well.",
        "Invite {keyword} in. It makes room for steadiness and care.",
        "Let {keyword} be the tone of your day. Gentle progress is still progress.",
        "With {keyword} in your heart, the next step feels lighter."
    ]

    private static let spanishKeywordTemplates: [String] = [
        "Deja que la {keyword} guíe tu próxima respiración. Puedes avanzar con suavidad.",
        "Mantén la {keyword} cerca un momento. Puede sostener tu siguiente paso.",
        "Elige la {keyword} hoy y deja que marque tu ritmo.",
        "Cuando te centras en la {keyword}, todo se aclara. Da un paso en calma.",
        "Que la {keyword} sea tu ancla. Desde aquí puedes avanzar con facilidad.",
        "Piensa en la {keyword} mientras avanzas. Te servirá de guía.",
        "Invita la {keyword}. Hace espacio para la calma y el cuidado.",
        "Deja que la {keyword} suavice tu camino. Lo estás haciendo bien.",
        "Que la {keyword} sea el tono de tu día. El progreso suave también cuenta.",
        "Con la {keyword} en el corazón, el siguiente paso se siente más ligero."
    ]
}
