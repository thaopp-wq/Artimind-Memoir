# Gen Prompts — Wedding Tribute Video

**Video duration**: 10 giây (cố định, Seedance output)
**Workflow**: fal.ai — `70f2c169-c9b6-4280-a554-5a526f1577cd` (PROD)
**Aspect ratio**: 9:16 (1080×1920)

---

## Quan hệ Script — Audio — Video

```
Script (app)     ──→  Nội dung mẫu, user tham khảo/chỉnh sửa. Không giới hạn độ dài.
Audio (upload)   ──→  Bản ghi âm thật. Bất kỳ độ dài nào.
Video (output)   ──→  Luôn 10 giây. Seedance lip-sync 10s đầu của audio.
```

Script KHÔNG quyết định duration video. Video luôn = 10s bất kể script dài bao nhiêu.

---

## API Call

```json
{
  "workflowId": "70f2c169-c9b6-4280-a554-5a526f1577cd",
  "input": {
    "files": ["{speaker_photo_path}", "{audio_path}"],
    "model": "seedance-2-0-lip-sync",
    "prompt": "{seedance_prompt}",
    "duration": 10,
    "resolution": "1080p",
    "aspectRatio": "9:16"
  }
}
```

---

## 1. A Dad's Blessing

`wedding_father_speech_01` — Father → Bride — 2 người

### Storyboard 10s

```
0s ─────── 2s ─────── 5s ─────── 8s ─────── 10s
│          │          │          │           │
│ Cha đứng │ Nói,     │ Tay đặt  │ Mỉm cười │
│ mỉm cười │ mắt hơi  │ lên ngực,│ ấm, gật  │
│ nhẹ,     │ ướt,     │ xúc động │ đầu nhẹ, │
│ nhìn     │ giọng    │ sâu,     │ bình yên │
│ camera   │ ấm áp    │ tự hào   │          │
│          │          │          │           │
│ Static   │ Slow push-in bắt đầu──────────│
└──────────┴──────────┴──────────┴───────────┘
```

### Seedance Prompt

```
A man in a dark suit stands in an elegant wedding venue with warm golden
lighting and white flowers. He looks at the camera with proud, glistening
eyes and speaks softly. One hand rests on his chest. The bride stands
beside him, listening with tears of joy. Soft candlelight bokeh. Slow
push-in on the speaker. Portrait 9:16, cinematic warm light, shallow DOF.
```

### Script (app template — user tham khảo)

**EN**:
> My dearest {bride_name}, today you begin a beautiful new chapter with {groom_name}. Even though I can't be there beside you, my love will always walk with you. I have watched you grow into the most wonderful person, and I know you will build a life full of joy together. You have always been my greatest pride. Be happy, my love. I am with you in every heartbeat.

**VI**:
> {bride_name} yêu thương của ba, hôm nay con bắt đầu một chương mới tuyệt đẹp cùng {groom_name}. Dù ba không thể ở bên cạnh con, tình yêu của ba sẽ luôn đồng hành cùng con. Ba đã dõi theo con lớn lên thành một người tuyệt vời, và ba biết hai con sẽ xây dựng một cuộc sống đầy niềm vui. Con luôn là niềm tự hào lớn nhất của ba. Hạnh phúc nhé con.

---

## 2. A Mom's Words

`wedding_mother_speech_01` — Mother → Groom — 2 người

### Storyboard 10s

```
0s ─────── 2s ─────── 5s ─────── 8s ─────── 10s
│          │          │          │           │
│ Mẹ đứng  │ Nói,     │ Xúc      │ Mỉm cười │
│ giữa vườn│ tay đưa  │ động,    │ rạng rỡ, │
│ hoa,     │ ra phía  │ mắt ướt, │ hít thở  │
│ mỉm cười │ trước    │ gật đầu  │ sâu,     │
│ dịu dàng │ nhẹ nhàng│ chậm     │ bình yên │
│          │          │          │           │
│ Static   │ Slow push-in bắt đầu──────────│
└──────────┴──────────┴──────────┴───────────┘
```

### Seedance Prompt

```
A woman in an elegant dress stands in a sunlit garden with lush greenery
and soft light through trees. She faces the camera with deep warmth, eyes
glistening with love. One hand reaches gently forward. The groom stands
beside her, hands clasped, looking moved. Rose petals and flower arch in
soft background. Slow push-in. Portrait 9:16, golden hour light, cinematic.
```

### Script

**EN**:
> My darling {groom_name}, today you become family with {bride_name}, and my heart overflows with love. I wish I could hold your hand one more time and tell you how proud I am of the person you've become. Cherish every moment together, hold each other through the storms, and never forget how deeply you are loved. Take care of each other. I love you both forever.

**VI**:
> {groom_name} yêu thương của mẹ, hôm nay con trở thành gia đình cùng {bride_name}, và trái tim mẹ tràn ngập yêu thương. Mẹ ước có thể nắm tay con một lần nữa và nói với con rằng mẹ tự hào biết bao. Hãy trân trọng từng khoảnh khắc bên nhau, nắm tay nhau qua mọi giông bão, và đừng bao giờ quên rằng các con được yêu thương vô bờ. Mẹ yêu các con mãi mãi.

---

## 3. Together in Spirit

`wedding_father_family_01` — Father → Both — 3 người

### Storyboard 10s

```
0s ─────── 2s ─────── 5s ─────── 8s ─────── 10s
│          │          │          │           │
│ Cha đứng │ Nói,     │ Nâng ly, │ Ly vẫn   │
│ đầu bàn, │ tự hào,  │ mỉm cười │ nâng,    │
│ tay cầm  │ nhìn     │ rộng,    │ gật đầu, │
│ ly,      │ thẳng    │ phấn     │ nụ cười  │
│ đèn dây  │ camera   │ khởi     │ ấm      │
│          │          │          │           │
│ Static ──│── Slow pull-out mở rộng cảnh──│
└──────────┴──────────┴──────────┴───────────┘
```

### Seedance Prompt

```
A man in a dark suit stands at the head of a long wooden dinner table with
string lights and candles. He holds a glass raised in a toast, speaking
with pride and joy. The bride and groom sit side by side across from him,
holding hands, smiling. Rustic-elegant reception, warm amber lighting.
Slow pull-out. Portrait 9:16, warm candlelight, cinematic.
```

### Script

**EN**:
> {bride_name} and {groom_name}, if I could be there tonight, I would raise my glass to you both. From the moment I saw you together, I knew you were made for each other. Build a life full of laughter, fill your home with love, and always remember that family is the greatest treasure. I am so proud of both of you. I am cheering for you from above, today and always.

**VI**:
> {bride_name} và {groom_name}, nếu ba có thể ở đây tối nay, ba sẽ nâng ly chúc mừng hai con. Từ khoảnh khắc ba thấy hai con bên nhau, ba biết hai con được sinh ra là dành cho nhau. Hãy xây dựng cuộc sống đầy tiếng cười, lấp đầy tổ ấm bằng yêu thương, và luôn nhớ rằng gia đình là báu vật lớn nhất. Ba rất tự hào về cả hai con. Ba luôn cổ vũ cho các con từ trên cao.

---

## 4. A Mother's Embrace

`wedding_mother_bride_01` — Mother → Bride — 2 người

### Storyboard 10s

```
0s ─────── 2s ─────── 5s ─────── 8s ─────── 10s
│          │          │          │           │
│ Mẹ đứng, │ Nói,     │ Mỉm cười │ Hít thở  │
│ ánh sáng │ tay đặt  │ qua nước │ sâu,     │
│ mềm qua  │ lên ngực,│ mắt,     │ nụ cười  │
│ cửa sổ,  │ yêu      │ gật đầu  │ bình yên,│
│ tĩnh lặng│ thương   │ nhẹ      │ buông tay│
│          │          │          │           │
│ Static camera giữ nguyên suốt 10s────────│
└──────────┴──────────┴──────────┴───────────┘
```

### Seedance Prompt

```
A woman in elegant attire stands in a bright bridal room with soft white
curtains and warm morning light from a window. She faces the camera with
deep love, one hand on her chest, smiling through glistening tears. The
bride stands nearby adjusting her veil. White flowers and mirror in soft
background. Static camera. Portrait 9:16, soft morning light, cinematic.
```

### Script

**EN**:
> My beautiful {bride_name}, I wish I could be the one fixing your veil today and telling you how stunning you look. {groom_name} is so lucky to have you. Remember, a strong marriage is built on kindness, patience, and laughter. You carry my love with you down that aisle. I am so proud of the woman you've become. Go shine, my darling.

**VI**:
> {bride_name} xinh đẹp của mẹ, mẹ ước được là người chỉnh lại khăn voan cho con hôm nay và nói con đẹp biết bao. {groom_name} thật may mắn khi có con. Hãy nhớ rằng một cuộc hôn nhân bền vững được xây bằng sự tử tế, kiên nhẫn và tiếng cười. Con mang theo tình yêu của mẹ bước xuống lễ đường. Mẹ rất tự hào về con. Hãy tỏa sáng nhé con gái.

---

## 5. A Father's Toast

`wedding_father_groom_01` — Father → Groom — 2 người

### Storyboard 10s

```
0s ─────── 2s ─────── 5s ─────── 8s ─────── 10s
│          │          │          │           │
│ Cha đứng,│ Nói,     │ Cười nhẹ,│ Nâng ly  │
│ tay cầm  │ tự hào,  │ ánh mắt  │ về phía  │
│ ly, nhìn │ chắc     │ dịu lại, │ camera,  │
│ camera   │ nịch,    │ tay đặt  │ mỉm cười │
│ tự tin   │ gật đầu  │ lên ngực │          │
│          │          │          │           │
│ Static ──│── Very slow push-in───────────│
└──────────┴──────────┴──────────┴───────────┘
```

### Seedance Prompt

```
A man in a formal dark suit stands confidently in a warm wedding reception
with amber candlelight. He holds a glass, speaking with quiet strength and
pride, looking directly at the camera. Steady expression with a gentle
smile. The groom stands beside him with respect. Dark wood and warm tones
in background. Very slow push-in. Portrait 9:16, amber lighting, cinematic.
```

### Script

**EN**:
> {groom_name}, I always knew this day would come. I have watched you grow from a boy who followed me everywhere into a man I deeply respect. {bride_name} sees in you what I have always known — a good heart. Marriage will test you, son. Be patient, be honest, and always show up. I raise my glass to you. Make us proud.

**VI**:
> {groom_name}, ba luôn biết ngày này sẽ đến. Ba đã nhìn con lớn lên từ cậu bé theo ba khắp nơi thành một người đàn ông mà ba vô cùng kính trọng. {bride_name} nhìn thấy ở con điều ba luôn biết — một trái tim tốt lành. Hôn nhân sẽ thử thách con. Hãy kiên nhẫn, hãy thành thật, và luôn có mặt. Ba nâng ly chúc con. Hãy làm ba tự hào.

---

## 6. A Mother's Prayer

`wedding_mother_family_01` — Mother → Both — 3 người

### Storyboard 10s

```
0s ─────── 2s ─────── 5s ─────── 8s ─────── 10s
│          │          │          │           │
│ Mẹ đứng, │ Nói,     │ Mở rộng  │ Chắp tay │
│ hai tay  │ dịu dàng,│ tay, như  │ lại,     │
│ chắp     │ mỉm cười │ muốn ôm  │ gật đầu  │
│ trước    │ xen lẫn  │ cả hai,  │ chậm,    │
│ ngực     │ xúc động │ mắt ướt  │ bình an  │
│          │          │          │           │
│ Static camera giữ nguyên suốt 10s────────│
└──────────┴──────────┴──────────┴───────────┘
```

### Seedance Prompt

```
A woman in elegant formal attire stands before a soft floral backdrop with
warm diffused backlight. Hands clasped at chest. She speaks with deep
maternal warmth, tender smile and glistening eyes, then opens arms gently.
Bride and groom stand nearby holding hands. White and blush flowers frame
the scene. Static camera. Portrait 9:16, soft diffused backlight, cinematic.
```

### Script

**EN**:
> {bride_name} and {groom_name}, looking at you two makes my heart so full. You have found in each other what the whole world searches for. Be gentle with each other's dreams, be the safe place when life gets hard, and fill your home with more laughter than tears. I am wrapping you both in my love from wherever I am. You are my answered prayer.

**VI**:
> {bride_name} và {groom_name}, nhìn hai con khiến trái tim mẹ tràn đầy. Các con đã tìm thấy ở nhau điều mà cả thế giới kiếm tìm. Hãy nhẹ nhàng với ước mơ của nhau, hãy là nơi bình yên khi cuộc sống khó khăn, và lấp đầy tổ ấm bằng tiếng cười nhiều hơn nước mắt. Mẹ ôm cả hai con bằng tình yêu từ nơi mẹ đang ở. Các con là lời cầu nguyện được đáp lại của mẹ.

---

## Prompt cheat sheet

| ID | Scene | Camera | Lighting |
|----|-------|--------|----------|
| `father_speech_01` | Wedding venue, golden, white flowers | Slow push-in | Warm golden |
| `mother_speech_01` | Sunlit garden, greenery, flower arch | Slow push-in | Golden hour |
| `father_family_01` | Dinner table, string lights, candles | Slow pull-out | Warm amber |
| `mother_bride_01` | Bridal room, curtains, mirror | Static | Soft morning |
| `father_groom_01` | Reception, dark wood, candlelight | Very slow push-in | Amber |
| `mother_family_01` | Floral backdrop, diffused light | Static | Soft backlight |

## Prompt rules

- KHÔNG mô tả khuôn mặt (Seedance lấy từ ảnh)
- KHÔNG nhắc lip-sync / mouth movement (Seedance tự xử lý từ audio)
- KHÔNG dùng tên riêng
- CÓ mô tả trang phục, tư thế, biểu cảm tổng thể
- CÓ mô tả bối cảnh, ánh sáng, camera
- CÓ "faces the camera" / "looks at the camera"
- Prompt dưới 80 từ
- Camera movement: tối đa 1 loại cho 10s (push-in HOẶC pull-out HOẶC static)
