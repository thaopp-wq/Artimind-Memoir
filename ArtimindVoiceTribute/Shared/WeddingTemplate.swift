import Foundation
import SwiftUI

// MARK: - CMS Template Model

struct WeddingTemplate: Identifiable, Hashable {
    let id: String
    let tag: String
    let title: String
    let status: TemplateStatus
    let thumbnail: String
    let videoPreview: String
    let audioPreview: String
    let speakerRole: SpeakerRole
    let peopleNumber: Int
    let scenePrompt: String
    let backgroundPrompt: String
    let nonSpeakerPrompt: String
    let scriptTemplates: [String: String]   // language code → script
    let requiresNames: Bool

    /// Returns the script for the user's current device language, falling back to English.
    var scriptTemplate: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return scriptTemplates[lang] ?? scriptTemplates["en"] ?? ""
    }
    let nameFields: [String]
    let photoLabels: [String]
    let speakerPhotoSlot: Int

    enum TemplateStatus: String {
        case active, draft
    }

    enum SpeakerRole: String {
        case father, mother
    }
}

// MARK: - Mock Data

extension WeddingTemplate {
    static let samples: [WeddingTemplate] = [
        WeddingTemplate(
            id: "wedding_father_speech_01",
            tag: "Wedding",
            title: "A Father's Blessing",
            status: .active,
            thumbnail: "explore-loved-ones",
            videoPreview: "",
            audioPreview: "",
            speakerRole: .father,
            peopleNumber: 2,
            scenePrompt: "An elegant wedding venue with warm golden lighting, white flowers, and soft bokeh in the background.",
            backgroundPrompt: "Warm, elegant wedding reception hall with soft candlelight and floral decorations.",
            nonSpeakerPrompt: "The bride stands beside the speaker, listening with tears of joy, gently holding their arm.",
            scriptTemplates: [
                "en": "My dearest {bride_name}, today you begin a beautiful new chapter with {groom_name}. Even though I can't be there beside you, my love will always walk with you. I have watched you grow into the most wonderful person, and I know you will build a life full of joy together. You have always been my greatest pride. Be happy, my love. I am with you in every heartbeat.",
                "vi": "{bride_name} yêu thương của ba, hôm nay con bắt đầu một chương mới tuyệt đẹp cùng {groom_name}. Dù ba không thể ở bên cạnh con, tình yêu của ba sẽ luôn đồng hành cùng con. Ba đã dõi theo con lớn lên thành một người tuyệt vời, và ba biết hai con sẽ xây dựng một cuộc sống đầy niềm vui. Con luôn là niềm tự hào lớn nhất của ba. Hạnh phúc nhé con.",
                "ja": "愛する{bride_name}、今日あなたは{groom_name}と新しい美しい章を始めます。私はそばにいられないけれど、私の愛はいつもあなたと共に歩みます。あなたが素晴らしい人に成長するのを見守ってきました。二人で喜びに満ちた人生を築いてください。あなたはいつも私の最大の誇りです。幸せにね。",
                "ko": "사랑하는 {bride_name}아, 오늘 너는 {groom_name}과 함께 아름다운 새 장을 시작하는구나. 아빠가 곁에 없지만, 아빠의 사랑은 언제나 너와 함께 걸을 거야. 네가 멋진 사람으로 자라는 걸 지켜봤어. 둘이 함께 기쁨 가득한 삶을 만들어가렴. 넌 항상 아빠의 가장 큰 자랑이야. 행복해라.",
                "zh": "最亲爱的{bride_name}，今天你和{groom_name}开始了美丽的新篇章。虽然爸爸不能在你身边，但我的爱会永远伴随着你。看着你成长为最美好的人，我知道你们会一起建造充满快乐的生活。你永远是爸爸最大的骄傲。幸福啊，我的宝贝。",
                "fr": "Ma très chère {bride_name}, aujourd'hui tu commences un nouveau chapitre magnifique avec {groom_name}. Même si je ne peux pas être à tes côtés, mon amour marchera toujours avec toi. Je t'ai regardée devenir une personne merveilleuse, et je sais que vous construirez une vie pleine de joie. Tu as toujours été ma plus grande fierté. Sois heureuse, mon amour.",
                "hi": "मेरी प्यारी {bride_name}, आज तुम {groom_name} के साथ एक खूबसूरत नई शुरुआत कर रही हो। भले ही मैं तुम्हारे पास नहीं हो सकता, मेरा प्यार हमेशा तुम्हारे साथ चलेगा। मैंने तुम्हें एक अद्भुत इंसान बनते देखा है। तुम हमेशा मेरा सबसे बड़ा गर्व रही हो। खुश रहो मेरी जान। मैं हर धड़कन में तुम्हारे साथ हूं।",
                "es": "Mi querida {bride_name}, hoy comienzas un nuevo capítulo hermoso con {groom_name}. Aunque no puedo estar a tu lado, mi amor siempre caminará contigo. Te he visto crecer hasta convertirte en la persona más maravillosa, y sé que juntos construirán una vida llena de alegría. Siempre has sido mi mayor orgullo. Sé feliz, mi amor. Estoy contigo en cada latido.",
                "pt": "Minha querida {bride_name}, hoje começas um novo capítulo maravilhoso com {groom_name}. Mesmo não podendo estar ao teu lado, o meu amor caminhará sempre contigo. Vi-te crescer e tornar-te numa pessoa extraordinária, e sei que juntos vão construir uma vida cheia de alegria. Foste sempre o meu maior orgulho. Sê feliz, meu amor.",
                "ru": "Моя дорогая {bride_name}, сегодня ты начинаешь прекрасную новую главу с {groom_name}. Хоть я не могу быть рядом, моя любовь всегда будет идти с тобой. Я наблюдал, как ты выросла в замечательного человека, и знаю, что вы построите жизнь, полную радости. Ты всегда была моей гордостью. Будь счастлива, родная.",
                "id": "{bride_name} tersayang, hari ini kamu memulai babak baru yang indah bersama {groom_name}. Meskipun ayah tidak bisa berada di sisimu, cinta ayah akan selalu menemanimu. Ayah menyaksikanmu tumbuh menjadi pribadi yang luar biasa, dan ayah tahu kalian akan membangun kehidupan yang penuh kebahagiaan. Kamu selalu menjadi kebanggaan terbesar ayah. Berbahagialah, sayang.",
                "fil": "Mahal kong {bride_name}, ngayon nagsisimula ka ng isang magandang bagong kabanata kasama si {groom_name}. Kahit hindi ako makapiling mo, ang pagmamahal ko ay laging kasama mo. Pinanood kitang lumaki at maging isang kahanga-hangang tao. Palagi kang naging pinakadakilang ipinagmamalaki ko. Maging masaya ka, anak ko. Kasama mo ako sa bawat tibok ng puso.",
                "bn": "আমার প্রিয় {bride_name}, আজ তুমি {groom_name}-এর সাথে একটি সুন্দর নতুন অধ্যায় শুরু করছ। আমি তোমার পাশে থাকতে না পারলেও, আমার ভালোবাসা সবসময় তোমার সাথে হাঁটবে। তোমাকে একজন অসাধারণ মানুষ হয়ে উঠতে দেখেছি। তুমি সবসময় আমার সবচেয়ে বড় গর্ব। সুখী হও, আমার সোনা।",
            ],
            requiresNames: true,
            nameFields: ["bride_name", "groom_name"],
            photoLabels: ["Upload a photo of the father", "Upload a photo of the bride"],
            speakerPhotoSlot: 0
        ),
        WeddingTemplate(
            id: "wedding_mother_speech_01",
            tag: "Wedding",
            title: "A Mother's Words",
            status: .active,
            thumbnail: "explore-restore",
            videoPreview: "",
            audioPreview: "",
            speakerRole: .mother,
            peopleNumber: 2,
            scenePrompt: "A beautiful garden wedding ceremony with lush greenery, soft sunlight filtering through trees.",
            backgroundPrompt: "Sunlit garden wedding with white chairs, rose petals on the aisle, and a wooden arch draped in flowers.",
            nonSpeakerPrompt: "The groom stands beside the speaker, looking moved and respectful, hands clasped in front.",
            scriptTemplates: [
                "en": "My darling {groom_name}, today you become family with {bride_name}, and my heart overflows with love. I wish I could hold your hand one more time and tell you how proud I am of the person you've become. Cherish every moment together, hold each other through the storms, and never forget how deeply you are loved. Take care of each other. I love you both forever.",
                "vi": "{groom_name} yêu thương của mẹ, hôm nay con trở thành gia đình cùng {bride_name}, và trái tim mẹ tràn ngập yêu thương. Mẹ ước có thể nắm tay con một lần nữa và nói với con rằng mẹ tự hào biết bao. Hãy trân trọng từng khoảnh khắc bên nhau, nắm tay nhau qua mọi giông bão, và đừng bao giờ quên rằng các con được yêu thương vô bờ. Mẹ yêu các con mãi mãi.",
                "ja": "愛する{groom_name}、今日あなたは{bride_name}と家族になります。あなたがどれほど素晴らしい人になったか、もう一度手を握って伝えたかった。一緒の時間を大切にして、嵐の中でも支え合って、どれほど深く愛されているか忘れないで。お互いを大切にね。二人を永遠に愛しています。",
                "ko": "사랑하는 {groom_name}아, 오늘 너는 {bride_name}과 가족이 되는구나. 엄마의 마음이 사랑으로 가득해. 한 번만 더 네 손을 잡고 네가 얼마나 자랑스러운지 말해주고 싶어. 함께하는 매 순간을 소중히 여기고, 서로를 꼭 잡아줘. 엄마가 둘 다 영원히 사랑해.",
                "zh": "亲爱的{groom_name}，今天你和{bride_name}成为一家人，妈妈的心充满了爱。多想再握一次你的手，告诉你妈妈有多骄傲。珍惜在一起的每一刻，风雨中彼此扶持，永远不要忘记你们被深深地爱着。互相照顾。妈妈永远爱你们。",
                "fr": "Mon cher {groom_name}, aujourd'hui tu deviens famille avec {bride_name}, et mon cœur déborde d'amour. J'aurais voulu te tenir la main une dernière fois et te dire combien je suis fière de toi. Chérissez chaque instant ensemble, soutenez-vous dans les tempêtes, et n'oubliez jamais combien vous êtes aimés. Prenez soin l'un de l'autre. Je vous aime pour toujours.",
                "hi": "मेरे प्यारे {groom_name}, आज तुम {bride_name} के साथ परिवार बन रहे हो, और मेरा दिल प्यार से भरा हुआ है। काश एक बार फिर तुम्हारा हाथ पकड़ कर बता पाती कि मुझे तुम पर कितना गर्व है। हर पल को संजो कर रखो, तूफानों में एक-दूसरे का साथ दो। एक-दूसरे का ख्याल रखो। मैं तुम दोनों से हमेशा प्यार करती हूं।",
                "es": "Mi querido {groom_name}, hoy te conviertes en familia con {bride_name}, y mi corazón se desborda de amor. Desearía poder tomar tu mano una vez más y decirte lo orgullosa que estoy de ti. Atesoren cada momento juntos, apóyense en las tormentas y nunca olviden cuánto son amados. Cuídense mutuamente. Los amo a los dos para siempre.",
                "pt": "Meu querido {groom_name}, hoje tornas-te família com {bride_name}, e o meu coração transborda de amor. Quem me dera segurar a tua mão mais uma vez e dizer-te o orgulho que sinto. Valorizem cada momento juntos, apoiem-se nas tempestades e nunca esqueçam o quanto são amados. Cuidem um do outro. Amo-vos para sempre.",
                "ru": "Мой дорогой {groom_name}, сегодня ты становишься семьей с {bride_name}, и мое сердце переполнено любовью. Как бы я хотела ещё раз взять тебя за руку и сказать, как горжусь тобой. Берегите каждый момент вместе, поддерживайте друг друга. Никогда не забывайте, как сильно вас любят. Я люблю вас обоих навеки.",
                "id": "{groom_name} sayang, hari ini kamu menjadi keluarga bersama {bride_name}, dan hati ibu dipenuhi cinta. Ibu berharap bisa memegang tanganmu sekali lagi dan memberitahumu betapa bangganya ibu. Hargai setiap momen bersama, saling menguatkan di masa sulit, dan jangan pernah lupa betapa kalian dicintai. Jaga satu sama lain. Ibu mencintai kalian selamanya.",
                "fil": "Mahal kong {groom_name}, ngayon nagiging pamilya ka na ni {bride_name}, at ang puso ko ay nag-uumapaw sa pagmamahal. Sana mahawakan ko ang kamay mo minsan pa at sabihing ipinagmamalaki kita. Pahalagahan ang bawat sandali, suportahan sa mga bagyo, at huwag kalimutang mahal na mahal kayo. Mag-ingat kayo sa isa't isa. Mahal ko kayo magpakailanman.",
                "bn": "আমার প্রিয় {groom_name}, আজ তুমি {bride_name}-এর সাথে পরিবার হচ্ছ, আর আমার হৃদয় ভালোবাসায় ভরে উঠেছে। আরেকবার তোমার হাত ধরে বলতে চাই তোমাকে নিয়ে কত গর্ব। প্রতিটি মুহূর্ত লালন করো, ঝড়ের মধ্যে একে অপরকে ধরে রাখো। একে অপরের যত্ন নিও। তোমাদের দুজনকে চিরকাল ভালোবাসি।",
            ],
            requiresNames: true,
            nameFields: ["bride_name", "groom_name"],
            photoLabels: ["Upload a photo of the mother", "Upload a photo of the groom"],
            speakerPhotoSlot: 0
        ),
        WeddingTemplate(
            id: "wedding_father_family_01",
            tag: "Wedding",
            title: "Together in Spirit",
            status: .active,
            thumbnail: "hero-memory",
            videoPreview: "",
            audioPreview: "",
            speakerRole: .father,
            peopleNumber: 3,
            scenePrompt: "A warm, intimate wedding dinner setting with soft string lights, family gathered around a long wooden table.",
            backgroundPrompt: "Rustic-elegant barn wedding reception with warm lighting, mason jars with candles, and string lights overhead.",
            nonSpeakerPrompt: "The bride and groom sit side by side across from the speaker, holding hands, smiling with emotion.",
            scriptTemplates: [
                "en": "{bride_name} and {groom_name}, if I could be there tonight, I would raise my glass to you both. From the moment I saw you together, I knew you were made for each other. Build a life full of laughter, fill your home with love, and always remember that family is the greatest treasure. I am so proud of both of you. I am cheering for you from above, today and always.",
                "vi": "{bride_name} và {groom_name}, nếu ba có thể ở đây tối nay, ba sẽ nâng ly chúc mừng hai con. Từ khoảnh khắc ba thấy hai con bên nhau, ba biết hai con được sinh ra là dành cho nhau. Hãy xây dựng cuộc sống đầy tiếng cười, lấp đầy tổ ấm bằng yêu thương, và luôn nhớ rằng gia đình là báu vật lớn nhất. Ba rất tự hào về cả hai con. Ba luôn cổ vũ cho các con từ trên cao.",
                "ja": "{bride_name}と{groom_name}、今夜そこにいられたら、二人に乾杯したかった。二人が一緒にいるのを見た瞬間、運命だと分かりました。笑い声に満ちた人生を築き、家を愛で満たし、家族が最大の宝物であることを忘れないで。二人をとても誇りに思います。いつも空から応援しているよ。",
                "ko": "{bride_name}과 {groom_name}, 오늘 밤 거기 있을 수 있다면 둘에게 건배했을 거야. 둘이 함께 있는 걸 본 순간, 서로를 위해 태어난 걸 알았어. 웃음 가득한 삶을 만들고, 사랑으로 가정을 채우고, 가족이 가장 큰 보물이라는 걸 기억해. 둘 다 너무 자랑스러워. 하늘에서 항상 응원할게.",
                "zh": "{bride_name}和{groom_name}，如果今晚我能在那里，我会举杯祝福你们。从看到你们在一起的那一刻，我就知道你们是天生一对。建造充满欢笑的生活，用爱填满你们的家，永远记住家人是最大的财富。爸爸为你们感到无比骄傲。爸爸在天上永远为你们加油。",
                "fr": "{bride_name} et {groom_name}, si je pouvais être là ce soir, je lèverais mon verre pour vous deux. Dès que je vous ai vus ensemble, j'ai su que vous étiez faits l'un pour l'autre. Construisez une vie pleine de rires, remplissez votre foyer d'amour, et rappelez-vous que la famille est le plus grand trésor. Je suis si fier de vous. Je vous encourage depuis là-haut, pour toujours.",
                "hi": "{bride_name} और {groom_name}, अगर आज रात मैं वहां होता, तो तुम दोनों के लिए अपना गिलास उठाता। जिस पल मैंने तुम्हें साथ देखा, मैं जान गया कि तुम एक-दूसरे के लिए बने हो। हंसी से भरी जिंदगी बनाओ, अपने घर को प्यार से भरो, और याद रखो कि परिवार सबसे बड़ा खजाना है। मुझे तुम दोनों पर बहुत गर्व है। ऊपर से हमेशा तुम्हारे साथ हूं।",
                "es": "{bride_name} y {groom_name}, si pudiera estar ahí esta noche, levantaría mi copa por ustedes. Desde el momento en que los vi juntos, supe que estaban hechos el uno para el otro. Construyan una vida llena de risas, llenen su hogar de amor y recuerden que la familia es el mayor tesoro. Estoy muy orgulloso de ambos. Los animo desde arriba, hoy y siempre.",
                "pt": "{bride_name} e {groom_name}, se eu pudesse estar aí esta noite, levantaria o meu copo por vocês. Desde o momento em que vos vi juntos, soube que eram feitos um para o outro. Construam uma vida cheia de risos, encham o vosso lar de amor e lembrem-se que a família é o maior tesouro. Tenho tanto orgulho de vocês. Estou a torcer por vocês lá de cima, para sempre.",
                "ru": "{bride_name} и {groom_name}, если бы я мог быть сегодня с вами, я бы поднял бокал за вас обоих. С первого момента, как увидел вас вместе, я понял — вы созданы друг для друга. Стройте жизнь, полную смеха, наполните дом любовью и помните, что семья — величайшее сокровище. Я так горжусь вами. Болею за вас сверху, сегодня и всегда.",
                "id": "{bride_name} dan {groom_name}, jika ayah bisa hadir malam ini, ayah akan mengangkat gelas untuk kalian berdua. Sejak pertama melihat kalian bersama, ayah tahu kalian ditakdirkan untuk satu sama lain. Bangunlah kehidupan penuh tawa, isi rumah kalian dengan cinta, dan ingatlah bahwa keluarga adalah harta terbesar. Ayah sangat bangga. Ayah mendukung kalian dari atas, selamanya.",
                "fil": "{bride_name} at {groom_name}, kung nandoon ako ngayong gabi, itatáas ko ang aking baso para sa inyong dalawa. Mula nang makita ko kayong magkasama, alam kong para sa isa't isa kayo. Bumuo ng buhay na puno ng tawanan, punuin ang tahanan ng pagmamahal, at tandaan na ang pamilya ang pinakadakilang kayamanan. Ipinagmamalaki ko kayo. Nandito ako mula sa itaas, ngayon at magpakailanman.",
                "bn": "{bride_name} এবং {groom_name}, আজ রাতে যদি আমি সেখানে থাকতে পারতাম, তোমাদের দুজনের জন্য গ্লাস তুলতাম। তোমাদের একসাথে দেখার মুহূর্তে বুঝেছিলাম তোমরা একে অপরের জন্য তৈরি। হাসিতে ভরা জীবন গড়ো, ভালোবাসায় ঘর ভরাও, আর মনে রেখো পরিবারই সবচেয়ে বড় সম্পদ। তোমাদের নিয়ে খুব গর্বিত। উপর থেকে সবসময় তোমাদের পাশে আছি।",
            ],
            requiresNames: true,
            nameFields: ["bride_name", "groom_name"],
            photoLabels: ["Upload a photo of the father", "Upload a photo of the bride", "Upload a photo of the groom"],
            speakerPhotoSlot: 0
        ),
    ]
}
