# Kịch bản nội dung — Wedding Tribute Video

**Feature**: IIP032 v5.8.0
**Pipeline**: Ảnh + Audio thật → fal.ai (Seedance 2.0) → Video lip-sync
**Cập nhật**: 2026-06-02

---

## 1. Tổng quan

### Sản phẩm

Video tribute ~20 giây, người đã mất "nói" lời chúc phúc tại đám cưới con. Video lip-sync AI từ ảnh chân dung + bản ghi âm giọng nói thật.

### Luồng nội dung

```
User upload ảnh speaker    ──┐
User upload audio thật     ──┤──→ fal.ai (Seedance 2.0) ──→ Video lip-sync 9:16
User tùy chỉnh script     ──┘
```

- **Ảnh**: Ảnh chân dung rõ mặt speaker (cha/mẹ đã mất)
- **Audio**: Bản ghi âm thật — voicemail, video cũ, ghi âm điện thoại, clip gia đình
- **Script**: Lời nhắn mẫu trong app — user có thể chỉnh sửa, dùng làm context cho prompt hoặc phụ đề

### Quy tắc nội dung

| Quy tắc | Chi tiết |
|---------|----------|
| Giọng văn | Ấm áp, chân thành, cảm xúc. Không phô trương, không sáo rỗng |
| Ngôi kể | Ngôi thứ nhất (speaker nói trực tiếp với con) |
| Độ dài script | 40–50 từ (tối ưu). App cho phép tối đa 50, mặc định ~55–65 để user cắt giảm |
| Placeholder | `{bride_name}` và `{groom_name}` — bắt buộc xuất hiện ít nhất 1 lần |
| Ngôn ngữ | 13 ngôn ngữ: en, vi, ja, ko, zh, fr, hi, es, pt, ru, id, fil, bn |
| Cảm xúc chủ đạo | Tự hào, yêu thương, tiếc nuối nhẹ (không bi lụy), chúc phúc |

---

## 2. Pipeline nội dung → fal.ai

### 2.1 Upload file lên storage

```
1. GET /api/v5/presigned-link  → nhận presignedUrl + filePath (cho ảnh)
2. PUT ảnh lên S3 qua presignedUrl
3. GET /api/v5/presigned-link  → nhận presignedUrl + filePath (cho audio)
4. PUT audio lên S3 qua presignedUrl
```

### 2.2 Gọi fal.ai workflow (async)

```
POST /api/v1/workflow/execute
```

```json
{
  "workflowId": "70f2c169-c9b6-4280-a554-5a526f1577cd",
  "input": {
    "files": [
      "<photo_path>",
      "<audio_path>"
    ],
    "model": "seedance-2-0-lip-sync",
    "prompt": "<seedance_prompt>",
    "duration": 20,
    "resolution": "1080p",
    "aspectRatio": "9:16"
  }
}
```

### 2.3 Cấu trúc prompt Seedance

Prompt được ghép từ 4 thành phần của template:

```
[scenePrompt]. [Speaker description from photo context].
[nonSpeakerPrompt].
[backgroundPrompt].
Camera: [camera direction]. Aspect ratio 9:16, cinematic lighting.
```

**Ví dụ prompt hoàn chỉnh:**

```
An elegant wedding venue with warm golden lighting, white flowers, and soft
bokeh. A father in a dark formal suit stands and speaks directly to the camera
with gentle emotion, slight tears of joy in his eyes. The bride stands beside
him, listening with tears of joy, gently holding his arm. Warm candlelight
and floral decorations fill the background. Camera slowly pushes in on the
speaker's face. Portrait 9:16, cinematic warm lighting, shallow depth of field.
```

### 2.4 Poll kết quả

```
GET /api/v1/workflow/execute/:runId
→ poll mỗi 2 giây cho đến khi status = "success" hoặc "failed"
```

---

## 3. Kịch bản template hiện tại

---

### 3.1 A Dad's Blessing

| Field | Giá trị |
|-------|---------|
| **ID** | `wedding_father_speech_01` |
| **Speaker** | Father |
| **Nói với** | Bride (con gái) |
| **Số người** | 2 (cha + con gái) |
| **Cảm xúc** | Tự hào, xúc động, chúc phúc |

#### Concept

Người cha đã mất nói lời chúc phúc cho con gái trong ngày cưới. Không gian tiệc cưới sang trọng, ấm áp. Cha đứng, nhìn thẳng vào camera như đang nói chuyện trực tiếp với con gái.

#### Mô tả cảnh (Visual Narrative)

| Thời gian | Hình ảnh | Cảm xúc |
|-----------|----------|---------|
| 0–3s | Speaker đứng, mỉm cười nhẹ, nhìn vào camera. Background tiệc cưới mờ sau lưng. | Bình tĩnh, ấm áp |
| 3–12s | Speaker nói, biểu cảm xúc động dần. Mắt hơi ướt. Tay đặt trước ngực. | Xúc động, tự hào |
| 12–18s | Speaker mỉm cười rạng rỡ, gật đầu nhẹ. Camera zoom in chậm. | Yêu thương, chúc phúc |
| 18–20s | Speaker nhìn camera, nụ cười ấm. Fade nhẹ. | Bình yên, trọn vẹn |

#### Seedance Prompt

```
An elegant wedding venue with warm golden lighting and white flower
arrangements. A middle-aged man in a dark formal suit stands facing the
camera. He speaks with gentle emotion, his eyes slightly glistening with
tears of joy. One hand rests on his chest. The bride stands beside him,
listening with tears of joy, gently holding his arm. Warm candlelight bokeh
in the background. The camera slowly pushes in toward the speaker's face.
Portrait 9:16, cinematic warm lighting, shallow depth of field, film grain.
```

#### Script mẫu

**EN** (62 từ):
> My dearest {bride_name}, today you begin a beautiful new chapter with {groom_name}. Even though I can't be there beside you, my love will always walk with you. I have watched you grow into the most wonderful person, and I know you will build a life full of joy together. You have always been my greatest pride. Be happy, my love. I am with you in every heartbeat.

**VI** (64 từ):
> {bride_name} yêu thương của ba, hôm nay con bắt đầu một chương mới tuyệt đẹp cùng {groom_name}. Dù ba không thể ở bên cạnh con, tình yêu của ba sẽ luôn đồng hành cùng con. Ba đã dõi theo con lớn lên thành một người tuyệt vời, và ba biết hai con sẽ xây dựng một cuộc sống đầy niềm vui. Con luôn là niềm tự hào lớn nhất của ba. Hạnh phúc nhé con.

#### Gợi ý audio thật

User nên tìm bản ghi âm cha trong các tình huống:
- Voicemail chúc mừng sinh nhật, ngày lễ
- Video gia đình có cha nói chuyện
- Ghi âm cuộc gọi điện thoại
- Clip cha phát biểu tại sự kiện gia đình

Thời lượng audio tối ưu: **10–30 giây**. Audio càng rõ giọng, ít tạp âm → video lip-sync càng tự nhiên.

---

### 3.2 A Mom's Words

| Field | Giá trị |
|-------|---------|
| **ID** | `wedding_mother_speech_01` |
| **Speaker** | Mother |
| **Nói với** | Groom (con trai/con rể) |
| **Số người** | 2 (mẹ + con trai) |
| **Cảm xúc** | Yêu thương sâu sắc, xúc động, dặn dò |

#### Concept

Người mẹ đã mất nói lời nhắn nhủ với con trai trong ngày cưới. Không gian vườn hoa tự nhiên, ánh nắng dịu. Mẹ đứng, ánh mắt ấm áp hướng về camera.

#### Mô tả cảnh (Visual Narrative)

| Thời gian | Hình ảnh | Cảm xúc |
|-----------|----------|---------|
| 0–3s | Speaker đứng giữa vườn hoa, mỉm cười dịu dàng, ánh nắng chiếu từ bên. | Bình yên, dịu dàng |
| 3–10s | Speaker nói, biểu cảm yêu thương. Tay đưa lên như muốn chạm vào camera. | Nhớ nhung, yêu thương |
| 10–16s | Speaker xúc động, mắt ướt nhẹ. Gật đầu chậm. | Xúc động, dặn dò |
| 16–20s | Speaker mỉm cười rạng rỡ, hít thở sâu. Camera pull back nhẹ. | Chấp nhận, chúc phúc |

#### Seedance Prompt

```
A beautiful garden wedding ceremony with lush greenery and soft sunlight
filtering through trees. A middle-aged woman in an elegant formal dress
stands facing the camera with a warm, loving expression. She speaks gently,
her eyes glistening with emotion, one hand reaching slightly forward. The
groom stands beside her, looking moved and respectful, hands clasped in
front. White chairs, rose petals on the aisle, and a wooden arch draped
in flowers visible in the background. Camera holds steady with a slow
gentle push in. Portrait 9:16, natural golden hour lighting, soft focus
background, cinematic.
```

#### Script mẫu

**EN** (67 từ):
> My darling {groom_name}, today you become family with {bride_name}, and my heart overflows with love. I wish I could hold your hand one more time and tell you how proud I am of the person you've become. Cherish every moment together, hold each other through the storms, and never forget how deeply you are loved. Take care of each other. I love you both forever.

**VI** (62 từ):
> {groom_name} yêu thương của mẹ, hôm nay con trở thành gia đình cùng {bride_name}, và trái tim mẹ tràn ngập yêu thương. Mẹ ước có thể nắm tay con một lần nữa và nói với con rằng mẹ tự hào biết bao. Hãy trân trọng từng khoảnh khắc bên nhau, nắm tay nhau qua mọi giông bão, và đừng bao giờ quên rằng các con được yêu thương vô bờ. Mẹ yêu các con mãi mãi.

#### Gợi ý audio thật

User nên tìm bản ghi âm mẹ trong các tình huống:
- Voicemail, tin nhắn thoại
- Video gia đình (nấu ăn, sinh nhật, tụ họp)
- Ghi âm mẹ hát ru hoặc kể chuyện
- Clip mẹ gọi điện

---

### 3.3 Together in Spirit

| Field | Giá trị |
|-------|---------|
| **ID** | `wedding_father_family_01` |
| **Speaker** | Father |
| **Nói với** | Bride + Groom (cả hai) |
| **Số người** | 3 (cha + cô dâu + chú rể) |
| **Cảm xúc** | Vui vẻ, nâng ly, chúc mừng |

#### Concept

Người cha đã mất "nâng ly" chúc mừng cả cô dâu lẫn chú rể tại bữa tiệc cưới. Không gian rustic ấm cúng, đèn dây, nến. Cha đứng đầu bàn tiệc, nhìn vào camera.

#### Mô tả cảnh (Visual Narrative)

| Thời gian | Hình ảnh | Cảm xúc |
|-----------|----------|---------|
| 0–3s | Speaker đứng đầu bàn tiệc dài, tay cầm ly. Đèn dây phía trên. | Trang trọng, vui vẻ |
| 3–10s | Speaker nói, biểu cảm tự hào. Nhìn thẳng camera. | Tự hào, phấn khởi |
| 10–16s | Speaker nâng ly, mỉm cười rộng. Camera capture cả cô dâu chú rể ngồi đối diện. | Chúc mừng, hạnh phúc |
| 16–20s | Speaker gật đầu, ly vẫn nâng, nụ cười ấm. | Trọn vẹn, mãn nguyện |

#### Seedance Prompt

```
A warm intimate wedding dinner setting with soft string lights overhead and
mason jars with candles on a long wooden table. A middle-aged man in a dark
suit stands at the head of the table, holding a glass raised in a toast. He
speaks with pride and joy, smiling broadly. The bride and groom sit side by
side across from him, holding hands and smiling with emotion. Rustic-elegant
barn reception with warm amber lighting. Camera slowly pulls out to reveal
the full scene. Portrait 9:16, warm cinematic lighting, shallow depth of field.
```

#### Script mẫu

**EN** (65 từ):
> {bride_name} and {groom_name}, if I could be there tonight, I would raise my glass to you both. From the moment I saw you together, I knew you were made for each other. Build a life full of laughter, fill your home with love, and always remember that family is the greatest treasure. I am so proud of both of you. I am cheering for you from above, today and always.

**VI** (66 từ):
> {bride_name} và {groom_name}, nếu ba có thể ở đây tối nay, ba sẽ nâng ly chúc mừng hai con. Từ khoảnh khắc ba thấy hai con bên nhau, ba biết hai con được sinh ra là dành cho nhau. Hãy xây dựng cuộc sống đầy tiếng cười, lấp đầy tổ ấm bằng yêu thương, và luôn nhớ rằng gia đình là báu vật lớn nhất. Ba rất tự hào về cả hai con. Ba luôn cổ vũ cho các con từ trên cao.

---

## 4. Kịch bản template mới

---

### 4.1 A Mother's Embrace

| Field | Giá trị |
|-------|---------|
| **ID** | `wedding_mother_bride_01` |
| **Speaker** | Mother |
| **Nói với** | Bride (con gái) |
| **Số người** | 2 (mẹ + con gái) |
| **Cảm xúc** | Dịu dàng, thân mật, xúc động sâu lắng |

#### Concept

Người mẹ đã mất nói với con gái trong phòng chuẩn bị cô dâu — khoảnh khắc riêng tư trước khi con gái bước ra lễ đường. Ánh sáng mềm qua rèm trắng, gương lớn phản chiếu. Mẹ đứng sau con gái, như đang giúp con chỉnh váy.

#### Mô tả cảnh (Visual Narrative)

| Thời gian | Hình ảnh | Cảm xúc |
|-----------|----------|---------|
| 0–3s | Speaker đứng trong phòng sáng, ánh sáng mềm từ cửa sổ. Rèm trắng bay nhẹ. | Tĩnh lặng, thân mật |
| 3–10s | Speaker nói, tay đặt lên ngực, biểu cảm yêu thương sâu sắc. Mắt nhìn thẳng camera. | Yêu thương, nhớ nhung |
| 10–16s | Speaker mỉm cười qua nước mắt, gật đầu nhẹ. Tay đưa ra phía trước. | Xúc động, khích lệ |
| 16–20s | Speaker hít thở sâu, nụ cười bình yên. Camera giữ nguyên. | Bình yên, buông tay |

#### Seedance Prompt

```
A bright bridal preparation room with soft white curtains gently swaying by
a window. Warm natural morning light streams in. A middle-aged woman in an
elegant outfit stands facing the camera with deep maternal love in her eyes.
She speaks softly, one hand on her chest, the other reaching forward gently.
Tears glisten in her eyes but she smiles through them. The bride stands
nearby, adjusting her veil, listening with emotion. A large mirror and fresh
white flowers visible in the soft-focus background. Camera holds steady with
minimal movement. Portrait 9:16, soft natural morning light, intimate mood,
cinematic.
```

#### Script mẫu

**EN** (58 từ):
> My beautiful {bride_name}, I wish I could be the one fixing your veil today and telling you how stunning you look. {groom_name} is so lucky to have you. Remember, a strong marriage is built on kindness, patience, and laughter. You carry my love with you down that aisle. I am so proud of the woman you've become. Go shine, my darling.

**VI** (61 từ):
> {bride_name} xinh đẹp của mẹ, mẹ ước được là người chỉnh lại khăn voan cho con hôm nay và nói con đẹp biết bao. {groom_name} thật may mắn khi có con. Hãy nhớ rằng một cuộc hôn nhân bền vững được xây bằng sự tử tế, kiên nhẫn và tiếng cười. Con mang theo tình yêu của mẹ bước xuống lễ đường. Mẹ rất tự hào về con. Hãy tỏa sáng nhé con gái.

**JA** (55 từ):
> 美しい{bride_name}、今日ベールを直してあげたかった。{groom_name}はあなたを迎えられて本当に幸せね。強い結婚は優しさと忍耐と笑顔で築かれるもの。バージンロードを歩く時、私の愛も一緒よ。あなたが成長した姿を誇りに思う。輝いてね、私の宝物。

**KO** (52 từ):
> 아름다운 {bride_name}아, 오늘 엄마가 너의 면사포를 고쳐주고 싶었어. {groom_name}은 너를 만나서 정말 행운이야. 좋은 결혼은 다정함과 인내와 웃음으로 만들어지는 거야. 버진로드를 걸을 때 엄마의 사랑도 함께야. 네가 자란 모습이 너무 자랑스러워. 빛나렴, 내 딸아.

**ZH** (48 từ):
> 美丽的{bride_name}，妈妈多想今天帮你整理头纱，告诉你有多美。{groom_name}能有你真幸福。记住，美好的婚姻建立在善良、耐心和欢笑之上。走过红毯时，妈妈的爱与你同行。为你骄傲，闪耀吧宝贝。

**FR** (64 từ):
> Ma belle {bride_name}, j'aurais tant voulu être celle qui ajuste ton voile aujourd'hui. {groom_name} a tellement de chance de t'avoir. Souviens-toi qu'un mariage solide se construit avec la gentillesse, la patience et le rire. Tu portes mon amour avec toi dans cette allée. Je suis si fière de la femme que tu es devenue. Brille, ma chérie.

**HI** (56 từ):
> मेरी खूबसूरत {bride_name}, काश आज मैं तुम्हारा घूंघट ठीक कर रही होती। {groom_name} बहुत भाग्यशाली है कि तुम उसकी हो। याद रखो, एक मजबूत शादी दयालुता, धैर्य और हंसी से बनती है। उस गलियारे में मेरा प्यार तुम्हारे साथ है। तुम जो बन गई हो उस पर मुझे गर्व है। चमको, मेरी जान।

**ES** (64 từ):
> Mi hermosa {bride_name}, ojalá pudiera ser yo quien arregle tu velo hoy. {groom_name} tiene tanta suerte de tenerte. Recuerda que un matrimonio fuerte se construye con amabilidad, paciencia y risas. Llevas mi amor contigo por ese pasillo. Estoy tan orgullosa de la mujer en que te has convertido. Brilla, mi amor.

**PT** (60 từ):
> Minha linda {bride_name}, quem me dera ser eu a ajustar o teu véu hoje. {groom_name} tem tanta sorte em ter-te. Lembra-te que um casamento forte se constrói com bondade, paciência e risos. Levas o meu amor contigo naquele corredor. Tenho tanto orgulho da mulher que te tornaste. Brilha, minha querida.

**RU** (54 từ):
> Моя красавица {bride_name}, как бы я хотела сегодня поправить твою фату. {groom_name} так повезло с тобой. Помни, крепкий брак строится на доброте, терпении и смехе. Мою любовь ты несёшь с собой к алтарю. Я так горжусь тобой. Сияй, моя родная.

**ID** (58 từ):
> {bride_name} cantikku, ibu berharap bisa memperbaiki kerudungmu hari ini. {groom_name} sangat beruntung memilikimu. Ingatlah, pernikahan yang kuat dibangun dari kebaikan, kesabaran, dan tawa. Kamu membawa cinta ibu bersamamu menuju altar. Ibu sangat bangga dengan wanita yang kamu jadi. Bersinarlah, sayangku.

**FIL** (58 từ):
> Maganda kong {bride_name}, sana ako ang nag-aayos ng belo mo ngayon. Napakaswerte ni {groom_name} na ikaw ang napiling kasama. Tandaan, ang matibay na kasal ay binuo ng kabaitan, pasensya, at tawanan. Dala mo ang pagmamahal ko sa pag-akyat mo sa altar. Ipinagmamalaki kita. Magningning ka, anak ko.

**BN** (52 từ):
> আমার সুন্দর {bride_name}, আজ তোমার ঘোমটা ঠিক করে দিতে চাইতাম। {groom_name} তোমাকে পেয়ে কত ভাগ্যবান। মনে রেখো, শক্তিশালী বিবাহ গড়ে ওঠে দয়া, ধৈর্য আর হাসিতে। সেই পথে আমার ভালোবাসা তোমার সাথে। তুমি যা হয়েছ তা নিয়ে গর্বিত। জ্বলে ওঠো, আমার মেয়ে।

---

### 4.2 A Father's Toast

| Field | Giá trị |
|-------|---------|
| **ID** | `wedding_father_groom_01` |
| **Speaker** | Father |
| **Nói với** | Groom (con trai) |
| **Số người** | 2 (cha + con trai) |
| **Cảm xúc** | Mạnh mẽ, tự hào, man-to-man |

#### Concept

Người cha đã mất nói với con trai trong đêm tiệc cưới. Tone chắc nịch, đàn ông — không quá ủy mị mà tự hào, khích lệ. Cha đứng với ly rượu, nhìn thẳng con trai qua camera.

#### Mô tả cảnh (Visual Narrative)

| Thời gian | Hình ảnh | Cảm xúc |
|-----------|----------|---------|
| 0–3s | Speaker đứng, tay cầm ly, nhìn vào camera chắc chắn. Ánh nến. | Trang trọng, ấm |
| 3–10s | Speaker nói, biểu cảm tự hào. Gật đầu nhẹ khi nhắc đến con trai. | Tự hào, mạnh mẽ |
| 10–16s | Speaker cười nhẹ, ánh mắt dịu lại. Tay tự do đặt lên ngực. | Xúc động kìm nén |
| 16–20s | Speaker nâng ly nhẹ về phía camera, mỉm cười. | Chúc mừng, chấp nhận |

#### Seedance Prompt

```
A warm wedding reception with soft amber lighting and candles on tables. A
middle-aged man in a formal dark suit stands confidently, holding a glass of
wine. He speaks with quiet strength and pride, looking directly at the camera.
His expression is steady and composed, with a gentle smile breaking through.
The groom stands beside him, looking up with respect and emotion. Dark wood
paneling and warm tones in the background. Camera holds steady with a very
slow push in. Portrait 9:16, warm amber candlelight, cinematic, dignified mood.
```

#### Script mẫu

**EN** (59 từ):
> {groom_name}, I always knew this day would come. I have watched you grow from a boy who followed me everywhere into a man I deeply respect. {bride_name} sees in you what I have always known — a good heart. Marriage will test you, son. Be patient, be honest, and always show up. I raise my glass to you. Make us proud.

**VI** (63 từ):
> {groom_name}, ba luôn biết ngày này sẽ đến. Ba đã nhìn con lớn lên từ cậu bé theo ba khắp nơi thành một người đàn ông mà ba vô cùng kính trọng. {bride_name} nhìn thấy ở con điều ba luôn biết — một trái tim tốt lành. Hôn nhân sẽ thử thách con. Hãy kiên nhẫn, hãy thành thật, và luôn có mặt. Ba nâng ly chúc con. Hãy làm ba tự hào.

**JA** (50 từ):
> {groom_name}、この日が来ると分かっていた。どこにでもついてきた少年が、心から尊敬する男になった。{bride_name}もお前の良さを分かっている。結婚は試練だ。忍耐強く、正直に、いつもそばにいろ。乾杯を贈る。誇りにさせてくれ。

**KO** (52 từ):
> {groom_name}아, 이 날이 올 줄 알았다. 아빠 뒤만 졸졸 따라다니던 꼬마가 진심으로 존경하는 남자가 됐구나. {bride_name}도 아빠가 아는 걸 보고 있어 — 착한 마음. 결혼은 시험이야. 인내하고, 정직하고, 항상 곁에 있어라. 건배한다. 우리를 자랑스럽게 해라.

**ZH** (46 từ):
> {groom_name}，爸爸一直知道这一天会来。看着那个到处跟着我的小男孩长成我深深尊敬的男人。{bride_name}看到了爸爸一直知道的——你善良的心。婚姻会考验你。耐心、诚实，永远在场。爸爸举杯祝你。让我们骄傲。

**FR** (62 từ):
> {groom_name}, j'ai toujours su que ce jour viendrait. J'ai vu le petit garçon qui me suivait partout devenir un homme que je respecte profondément. {bride_name} voit en toi ce que j'ai toujours su — un bon cœur. Le mariage te mettra à l'épreuve. Sois patient, sois honnête, sois toujours présent. Je lève mon verre pour toi. Rends-nous fiers.

**HI** (54 từ):
> {groom_name}, मुझे हमेशा पता था कि यह दिन आएगा। मेरे पीछे-पीछे घूमने वाले लड़के को एक ऐसे आदमी में बदलते देखा जिसका मैं सम्मान करता हूं। {bride_name} वो देखती है जो मैं हमेशा जानता था — एक अच्छा दिल। शादी तुम्हारी परीक्षा लेगी। धैर्य रखो, ईमानदार रहो। मेरा गिलास तुम्हारे लिए। हमें गर्व दिलाओ।

**ES** (62 từ):
> {groom_name}, siempre supe que este día llegaría. He visto al niño que me seguía a todas partes convertirse en un hombre al que respeto profundamente. {bride_name} ve en ti lo que siempre he sabido — un buen corazón. El matrimonio te pondrá a prueba. Sé paciente, sé honesto y siempre aparece. Levanto mi copa por ti. Haznos sentir orgullosos.

**PT** (60 từ):
> {groom_name}, sempre soube que este dia chegaria. Vi o rapaz que me seguia para todo o lado tornar-se num homem que respeito profundamente. {bride_name} vê em ti o que sempre soube — um bom coração. O casamento vai testar-te. Sê paciente, sê honesto e está sempre presente. Levanto o meu copo por ti. Orgulha-nos.

**RU** (52 từ):
> {groom_name}, я всегда знал, что этот день настанет. Мальчишка, что ходил за мной повсюду, стал мужчиной, которого я глубоко уважаю. {bride_name} видит в тебе то, что я всегда знал — доброе сердце. Брак испытает тебя. Будь терпелив, честен и всегда рядом. Поднимаю бокал за тебя. Сделай нас гордыми.

**ID** (58 từ):
> {groom_name}, ayah selalu tahu hari ini akan tiba. Ayah melihat anak kecil yang mengikuti ayah ke mana-mana tumbuh menjadi pria yang ayah hormati. {bride_name} melihat apa yang ayah selalu tahu — hati yang baik. Pernikahan akan mengujimu. Sabarlah, jujurlah, dan selalu hadir. Ayah angkat gelas untukmu. Buatlah kami bangga.

**FIL** (55 từ):
> {groom_name}, alam ko na darating ang araw na ito. Pinanood kitang lumaki mula sa batang sumusunod sa akin papunta sa lalaking lubos kong iginagalang. Nakikita ni {bride_name} ang lagi kong alam — mabuting puso. Susubukin ka ng kasal. Maging matiyaga, matapat, at laging nandyan. Itataas ko ang baso ko para sa iyo. Ipagmalaki mo kami.

**BN** (50 từ):
> {groom_name}, আমি সবসময় জানতাম এই দিন আসবে। আমার পিছু পিছু ঘুরে বেড়ানো ছেলেটিকে এমন একজন মানুষ হতে দেখেছি যাকে গভীরভাবে শ্রদ্ধা করি। {bride_name} তোমার মধ্যে দেখে যা আমি সবসময় জানতাম — ভালো হৃদয়। বিয়ে পরীক্ষা নেবে। ধৈর্য ধরো, সৎ থাকো। তোমার জন্য গ্লাস তুলছি। আমাদের গর্বিত করো।

---

### 4.3 A Mother's Prayer

| Field | Giá trị |
|-------|---------|
| **ID** | `wedding_mother_family_01` |
| **Speaker** | Mother |
| **Nói với** | Bride + Groom (cả hai) |
| **Số người** | 3 (mẹ + cô dâu + chú rể) |
| **Cảm xúc** | Trìu mến, bao dung, chúc phúc từ xa |

#### Concept

Người mẹ đã mất chúc phúc cho cả cô dâu lẫn chú rể. Không gian nhà thờ hoặc lễ đường, ánh sáng xuyên qua cửa kính màu. Mẹ đứng như đang phát biểu tại lễ cưới, hai tay đặt trước ngực.

#### Mô tả cảnh (Visual Narrative)

| Thời gian | Hình ảnh | Cảm xúc |
|-----------|----------|---------|
| 0–3s | Speaker đứng trước backdrop hoa, ánh sáng mềm từ phía sau. Hai tay chắp trước ngực. | Trang nghiêm, yêu thương |
| 3–10s | Speaker nói, biểu cảm bao dung. Mỉm cười dịu dàng xen lẫn xúc động. | Trìu mến, dặn dò |
| 10–16s | Speaker mở rộng tay, như muốn ôm cả hai. Mắt ướt nhẹ. | Bao dung, chúc phúc |
| 16–20s | Speaker chắp tay lại, gật đầu chậm, nụ cười bình yên. | Bình an, viên mãn |

#### Seedance Prompt

```
A graceful wedding ceremony backdrop with soft floral arrangements and warm
diffused light coming from behind. A middle-aged woman in elegant formal attire
stands facing the camera with her hands clasped at her chest. She speaks with
deep maternal warmth, her expression alternating between tender smiles and
glistening eyes. She opens her arms gently as if to embrace. The bride and
groom stand together nearby, holding hands, looking at her with love. Soft
white and blush pink flowers frame the scene. Camera holds steady with gentle
breathing movement. Portrait 9:16, soft diffused backlight, warm tones, cinematic.
```

#### Script mẫu

**EN** (60 từ):
> {bride_name} and {groom_name}, looking at you two makes my heart so full. You have found in each other what the whole world searches for. Be gentle with each other's dreams, be the safe place when life gets hard, and fill your home with more laughter than tears. I am wrapping you both in my love from wherever I am. You are my answered prayer.

**VI** (63 từ):
> {bride_name} và {groom_name}, nhìn hai con khiến trái tim mẹ tràn đầy. Các con đã tìm thấy ở nhau điều mà cả thế giới kiếm tìm. Hãy nhẹ nhàng với ước mơ của nhau, hãy là nơi bình yên khi cuộc sống khó khăn, và lấp đầy tổ ấm bằng tiếng cười nhiều hơn nước mắt. Mẹ ôm cả hai con bằng tình yêu từ nơi mẹ đang ở. Các con là lời cầu nguyện được đáp lại của mẹ.

**JA** (49 từ):
> {bride_name}と{groom_name}、二人を見ていると胸がいっぱい。世界中が探し求めるものを見つけたのね。互いの夢を大切にして、辛い時は安らぎの場所になって、涙より笑顔で家を満たして。どこにいても二人を愛で包んでいるわ。あなたたちは私の祈りの答え。

**KO** (50 từ):
> {bride_name}과 {groom_name}, 너희 둘을 보면 마음이 가득 차. 온 세상이 찾는 것을 서로에게서 찾았구나. 서로의 꿈을 소중히 하고, 힘들 때 서로의 안식처가 되고, 눈물보다 웃음으로 집을 채워라. 어디에서든 사랑으로 너희를 감싸고 있어. 너희는 엄마의 기도의 응답이야.

**ZH** (45 từ):
> {bride_name}和{groom_name}，看着你们两个，妈妈的心好满。你们在彼此身上找到了全世界都在寻找的东西。温柔对待彼此的梦想，困难时成为对方的港湾，用笑声而非泪水填满你们的家。无论妈妈在哪里，都用爱包围着你们。你们是妈妈祈祷的回应。

**FR** (66 từ):
> {bride_name} et {groom_name}, vous voir tous les deux remplit mon cœur. Vous avez trouvé l'un dans l'autre ce que le monde entier cherche. Soyez doux avec les rêves de l'autre, soyez le refuge quand la vie devient dure, et remplissez votre foyer de plus de rires que de larmes. Je vous enveloppe tous les deux de mon amour d'où que je sois. Vous êtes ma prière exaucée.

**HI** (55 từ):
> {bride_name} और {groom_name}, तुम दोनों को देखकर मेरा दिल भर आता है। तुमने एक-दूसरे में वो पाया है जो पूरी दुनिया खोजती है। एक-दूसरे के सपनों को सहेजो, मुश्किल में सहारा बनो, और अपने घर को आंसुओं से ज्यादा हंसी से भरो। जहां भी हूं, अपने प्यार से तुम्हें लपेटे हुए हूं। तुम मेरी दुआ का जवाब हो।

**ES** (63 từ):
> {bride_name} y {groom_name}, verlos juntos me llena el corazón. Han encontrado el uno en el otro lo que todo el mundo busca. Sean gentiles con los sueños del otro, sean el refugio cuando la vida sea difícil, y llenen su hogar con más risas que lágrimas. Los envuelvo a ambos en mi amor desde donde estoy. Son mi oración respondida.

**PT** (60 từ):
> {bride_name} e {groom_name}, ver-vos juntos enche-me o coração. Encontraram um no outro o que o mundo inteiro procura. Sejam gentis com os sonhos um do outro, sejam o porto seguro quando a vida apertar, e encham a vossa casa com mais risos que lágrimas. Envolvo-vos no meu amor de onde quer que eu esteja. Vocês são a minha oração atendida.

**RU** (56 từ):
> {bride_name} и {groom_name}, глядя на вас, моё сердце переполняется. Вы нашли друг в друге то, что ищет весь мир. Берегите мечты друг друга, будьте убежищем в трудные дни и наполните дом смехом больше, чем слезами. Я обнимаю вас любовью, где бы я ни была. Вы — мой исполнившийся молитвенный ответ.

**ID** (58 từ):
> {bride_name} dan {groom_name}, melihat kalian berdua membuat hati ibu penuh. Kalian menemukan satu sama lain apa yang dicari seluruh dunia. Lembutlah dengan mimpi masing-masing, jadilah tempat aman saat hidup sulit, dan isi rumah dengan lebih banyak tawa daripada air mata. Ibu memeluk kalian dengan cinta dari mana pun ibu berada. Kalian adalah doa ibu yang terjawab.

**FIL** (57 từ):
> {bride_name} at {groom_name}, ang puso ko ay puno sa inyong dalawa. Natagpuan ninyo sa isa't isa ang hinahanap ng buong mundo. Maging malumanay sa pangarap ng bawat isa, maging tahanan kapag mahirap ang buhay, at punuin ang bahay ng tawanan kaysa luha. Niyayakap ko kayo ng pagmamahal ko saan man ako naroon. Kayo ang sagot sa dalangin ko.

**BN** (50 từ):
> {bride_name} এবং {groom_name}, তোমাদের দেখে হৃদয় ভরে যায়। সারা পৃথিবী যা খোঁজে তা তোমরা একে অপরের মধ্যে পেয়েছ। পরস্পরের স্বপ্নকে যত্ন করো, কঠিন সময়ে আশ্রয় হও, আর চোখের জলের চেয়ে হাসি দিয়ে ঘর ভরাও। যেখানেই থাকি, ভালোবাসায় জড়িয়ে আছি। তোমরা আমার প্রার্থনার উত্তর।

---

## 5. Tổng hợp template

| # | ID | Title | Speaker | Nói với | Số người | Tone |
|---|-----|-------|---------|---------|----------|------|
| 1 | `wedding_father_speech_01` | A Dad's Blessing | Father | Bride | 2 | Xúc động, tự hào |
| 2 | `wedding_mother_speech_01` | A Mom's Words | Mother | Groom | 2 | Yêu thương, dặn dò |
| 3 | `wedding_father_family_01` | Together in Spirit | Father | Both | 3 | Vui vẻ, nâng ly |
| 4 | `wedding_mother_bride_01` | A Mother's Embrace | Mother | Bride | 2 | Dịu dàng, thân mật |
| 5 | `wedding_father_groom_01` | A Father's Toast | Father | Groom | 2 | Mạnh mẽ, man-to-man |
| 6 | `wedding_mother_family_01` | A Mother's Prayer | Mother | Both | 3 | Bao dung, chúc phúc |

### Ma trận đầy đủ

|  | → Bride | → Groom | → Both |
|--|---------|---------|--------|
| **Father** | A Dad's Blessing | A Father's Toast | Together in Spirit |
| **Mother** | A Mother's Embrace | A Mom's Words | A Mother's Prayer |

---

## 6. Hướng dẫn viết thêm script

### 6.1 Nguyên tắc cảm xúc

- **Mở đầu**: Gọi tên trực tiếp, tạo kết nối ngay (`My dearest...`, `Con yêu...`)
- **Thân**: 1 ký ức cụ thể HOẶC 1 lời khuyên chân thành. Không nhồi cả hai.
- **Kết**: Lời chúc + khẳng định sự hiện diện (`I am with you...`, `Ba luôn ở bên...`)
- **Tránh**: sáo rỗng tôn giáo, quá bi thương, quá dài dòng

### 6.2 Nguyên tắc viết prompt Seedance

```
[Bối cảnh cụ thể] + [Mô tả speaker: tuổi, trang phục, tư thế, biểu cảm] +
[Mô tả hành động: nói, cử chỉ tay] + [Non-speaker: vị trí, phản ứng] +
[Background chi tiết] + [Camera movement] + [Technical: 9:16, lighting, mood]
```

**Dos:**
- Mô tả cụ thể ánh sáng (candle, golden hour, window light)
- Chỉ rõ biểu cảm (tears of joy, gentle smile, steady gaze)
- Luôn có "facing the camera" / "looking directly at camera"
- Kết thúc bằng technical specs (Portrait 9:16, cinematic)

**Don'ts:**
- Không mô tả khuôn mặt cụ thể (Seedance lấy từ ảnh upload)
- Không dùng tên riêng trong prompt
- Không yêu cầu text/chữ xuất hiện trong video
- Không mô tả lip movement (Seedance tự sync từ audio)

### 6.3 Độ dài tối ưu

| Thành phần | Tối ưu | Tối đa |
|-----------|--------|--------|
| Script (EN) | 45–55 từ | 65 từ |
| Script (VI) | 50–60 từ | 70 từ |
| Seedance prompt | 60–80 từ | 100 từ |
| Audio upload | 10–25 giây | 30 giây |
| Video output | 15–20 giây | 25 giây |

---

## 7. Checklist

- [x] 6 template wedding (ma trận 2×3: Father/Mother × Bride/Groom/Both)
- [x] Script mẫu 13 ngôn ngữ cho mỗi template
- [x] Seedance prompt cho mỗi template
- [x] Visual narrative (mô tả cảnh theo timeline)
- [x] Pipeline fal.ai workflow documented
- [x] Hướng dẫn viết thêm script + prompt
- [ ] Review script bởi native speaker cho từng ngôn ngữ
- [ ] Test prompt thực tế trên Seedance 2.0
- [ ] Fine-tune duration/camera theo kết quả test
- [ ] Bổ sung gợi ý audio cho từng template mới
