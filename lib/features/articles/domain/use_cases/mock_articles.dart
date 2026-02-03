import '../entities/article.dart';
import '../entities/author.dart';

final List<Author> mockAuthors = [
  Author(
    id: 'auth_1',
    name: 'Ava Thompson',
    bio: 'Tech journalist covering AI, cloud, and developer tooling.',
    avatarUrl: 'https://picsum.photos/seed/auth_1/200/200',
  ),
  Author(
    id: 'auth_2',
    name: 'Liam Chen',
    bio: 'Productivity writer exploring workflows and remote teams.',
    avatarUrl: 'https://picsum.photos/seed/auth_2/200/200',
  ),
  Author(
    id: 'auth_3',
    name: 'Sofia Ramirez',
    bio: 'Climate and energy correspondent with a focus on renewables.',
    avatarUrl: 'https://picsum.photos/seed/auth_3/200/200',
  ),
];

final List<Article> mockArticles = [
  Article(
    id: 'article-1',
    title: 'AI Is Reshaping the Future of Work',
    summary:
        'Copilots are shifting knowledge work from execution to supervision; judgment quality and explainability now define trust.',
    body: '''
Knowledge work is shifting from **execution** to *supervision*, as copilots slide into every role from finance to field ops. The real delta isn’t output speed—it’s judgment quality.

## What changes first
- Approval chains compress as drafts arrive fully formed.
- Managers now coach on prompts, not just outcomes.
- Compliance teams run parallel reviews on AI-assisted decisions.

### Culture has to catch up
Teams that narrate their decisions keep trust high. Silent automation erodes confidence.

> “If you can’t explain how a decision was shaped, you can’t defend it,” notes chief risk officer Nia Malik.

## The near-term playbook
1. Publish guidelines on acceptable AI use.
2. Track when and where generated text enters the workflow.
3. Incentivize *explanations* over raw velocity.

The companies that win will pair model literacy with humane pacing—protecting focus while keeping humans firmly in the loop.
''',
    author: mockAuthors[0],
    coverImageUrl: 'https://picsum.photos/seed/article-1/800/600',
    tags: ['AI', 'Work'],
    readingTimeMinutes: 7,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-12T09:00:00Z'),
    updatedAt: DateTime.parse('2026-01-12T09:00:00Z'),
  ),
  Article(
    id: 'article-2',
    title: 'Global Markets React to New Tech Policies',
    summary:
        'Coordinated EU/US guidance on cross-border data exports is reshaping contracts, timelines, and localization strategies.',
    body: '''
Coordinated guidance on cross-border data exports from the EU and US has jolted cloud providers and fintechs that rely on frictionless flows.

## Why this matters
**Risk premiums** are reappearing in contracts, and CFOs are re-forecasting margins for 2026.

### Early signals
- Deal cycles lengthened by 2–3 weeks.
- Banks are asking for *provable residency* for telemetry.
- Startups are decoupling analytics from PII in staging.

> “Data localization isn’t a toggle—it’s a portfolio strategy,” says policy analyst René Dubois.

## What to watch
Expect phased enforcement tied to certifications. Firms that pre-invest in region-aware architectures will regain speed while competitors renegotiate SLAs.
''',
    author: mockAuthors[1],
    coverImageUrl: 'https://picsum.photos/seed/article-2/800/600',
    tags: ['Policy', 'Markets'],
    readingTimeMinutes: 8,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-11T14:30:00Z'),
    updatedAt: DateTime.parse('2026-01-11T14:30:00Z'),
  ),
  Article(
    id: 'article-3',
    title: 'How Deep Focus Became a Competitive Advantage',
    summary:
        'Teams defending focus blocks and async rituals are shipping harder work with calmer cadence and measurable flow gains.',
    body: '''
After a decade of alerts, teams are rediscovering *protected focus* as a differentiator. Output on complex projects tracks directly to uninterrupted hours.

## The calendar rewrite
Leaders are carving **no-meeting blocks** that span time zones, pairing them with async decision logs.

### Metrics that matter
- Flow sessions per week per IC
- Context switches avoided
- Cycle time on deep tasks

> “We measure meetings skipped as a success metric,” says product lead Maren Ito.

## Small rituals, big gains
Daily intent posts, shared silence windows, and recap threads create rhythm without noise. Teams that defend focus are shipping harder problems—calmly.
''',
    author: mockAuthors[2],
    coverImageUrl: 'https://picsum.photos/seed/article-3/800/600',
    tags: ['Productivity', 'Culture'],
    readingTimeMinutes: 6,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-10T08:45:00Z'),
    updatedAt: DateTime.parse('2026-01-10T08:45:00Z'),
  ),
  Article(
    id: 'article-4',
    title: 'Energy Storage Breakthroughs Explained',
    summary:
        'LFP chemistry, safer supply chains, and containerized packs are accelerating grid-scale storage deployments.',
    body: '''
Grid operators are leaning on **LFP chemistry** as prices fall and safety margins rise, redefining how quickly renewable projects can go live.

## What flipped the curve
- Supply chain resilience in cathode materials
- Better thermal stability vs. NMC
- *Standardized* containerized formats for faster installs

### The science, briefly
Slower degradation under high-cycle duty makes LFP ideal for frequency response and peak shaving.

> “The new constraint is interconnection, not storage tech,” notes energy analyst Priya Das.

## Deployment playbook
Pair utility-scale solar with 4–6 hour packs, pre-stage swap units, and negotiate flexible offtake tied to storage availability.
''',
    author: mockAuthors[0],
    coverImageUrl: 'https://picsum.photos/seed/article-4/800/600',
    tags: ['Energy', 'Climate'],
    readingTimeMinutes: 9,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-09T11:10:00Z'),
    updatedAt: DateTime.parse('2026-01-09T11:10:00Z'),
  ),
  Article(
    id: 'article-5',
    title: 'Designing Trust in AI-Powered Products',
    summary:
        'Transparent UI patterns, explainability chips, and opt-outs are becoming the default trust contract for adaptive products.',
    body: '''
Trust is now a product surface. Teams are shipping **transparency UIs**, inline explanations, and opt-outs to keep adaptive features welcome.

## Patterns that work
- *Why this suggestion?* chips next to recommendations
- Model cards surfaced at the point of choice
- Granular controls that remember context

### Avoiding dark patterns
Users can feel when autonomy is eroded. Clarity beats persuasion.

> “If trust costs clicks, pay it,” says design director Hao Nguyen.

## Rollout sequencing
Start with explainable defaults, measure sentiment, then layer optional personalization. The trust you build now compounds across launches.
''',
    author: mockAuthors[1],
    coverImageUrl: 'https://picsum.photos/seed/article-5/800/600',
    tags: ['Design', 'AI'],
    readingTimeMinutes: 5,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-08T10:05:00Z'),
    updatedAt: DateTime.parse('2026-01-08T10:05:00Z'),
  ),
  Article(
    id: 'article-6',
    title: 'The Quiet Comeback of Night Trains in Europe',
    summary:
        'Refurbished sleepers, bundled passes, and climate-first policies are turning night trains into durable infrastructure.',
    body: '''
Night trains are back—not as nostalgia, but as a **climate-conscious alternative** to short-haul flights. Refurbished sleepers and bundled passes are lowering friction.

## Demand drivers
- Corporate travel policies favoring rail under 800 km
- Integrated ticketing with local transit on arrival
- Softer security flow versus airports

### Passenger experience
Cabins borrow from boutique hotels: dimmable light, linen upgrades, and quiet zones.

> “Arriving rested changes the entire trip calculus,” says mobility strategist Erik Lind.

## Next on the timetable
Expect new north–south corridors and dynamic pricing tuned to shoulder seasons. The quiet comeback is becoming durable infrastructure.
''',
    author: mockAuthors[2],
    coverImageUrl: 'https://picsum.photos/seed/article-6/800/600',
    tags: ['Transport', 'Travel'],
    readingTimeMinutes: 7,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-07T06:40:00Z'),
    updatedAt: DateTime.parse('2026-01-07T06:40:00Z'),
  ),
  Article(
    id: 'article-7',
    title: 'Why Local Newsrooms Are Turning to Memberships',
    summary:
        'Memberships with open budgets and member briefings are stabilizing local desks beyond ad swings.',
    body: '''
Local desks are rebuilding resilience with **memberships**—trading ad volatility for predictable community backing.

## What members get
- Weekly briefings with reporter notes
- Early looks at investigations
- Open budgets that show how funds are used

### Operational shifts
Newsrooms are hiring *audience editors* who translate investigations into member updates.

> “Transparency is our moat,” says managing editor Chloe Grant.

## Sustainability metrics
Renewal rate, investigation cadence, and member referrals now sit on the same dashboard as traffic. Stability follows when trust becomes the product.
''',
    author: mockAuthors[0],
    coverImageUrl: 'https://picsum.photos/seed/article-7/800/600',
    tags: ['Media', 'Business'],
    readingTimeMinutes: 4,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-06T13:20:00Z'),
    updatedAt: DateTime.parse('2026-01-06T13:20:00Z'),
  ),
  Article(
    id: 'article-8',
    title: 'Developers Embrace On-Device AI for Privacy',
    summary:
        'Edge models keep personal data local, cutting latency while offering privacy-as-a-feature for everyday tools.',
    body: '''
On-device models are moving beyond demos into everyday tooling—keeping **personal data local** while slashing latency.

## Where it lands first
- Note-taking with offline transcription
- Translation tuned to domain glossaries
- Summaries that never touch the cloud

### Engineering constraints
Quantization and distillation keep models under thermal and battery limits.

> “Privacy isn’t a feature toggle; it’s an architecture choice,” says staff engineer Rina Patel.

## Product implications
Expect premium tiers that guarantee offline-by-default. Confidence rises when the green “local” badge replaces upload spinners.
''',
    author: mockAuthors[1],
    coverImageUrl: 'https://picsum.photos/seed/article-8/800/600',
    tags: ['AI', 'Privacy'],
    readingTimeMinutes: 6,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-05T09:55:00Z'),
    updatedAt: DateTime.parse('2026-01-05T09:55:00Z'),
  ),
  Article(
    id: 'article-9',
    title: 'Cities Rethink Heat Resilience Ahead of Summer',
    summary:
        'Cities are funding shaded corridors, misting hubs, and cool roofs as frontline heat resilience infrastructure.',
    body: '''
With another record summer looming, cities are prioritizing **shaded corridors** and rapid-deploy cooling to protect residents.

## The design toolkit
- Tree canopy targets by block
- Misting hubs near transit interchanges
- Cool roofs mandated on public buildings

### Community-first moves
Libraries and schools stay open late as cooling anchors.

> “Heat is a social equity issue before it’s an engineering one,” notes planner Dana Ortiz.

## Funding the build-out
Blended finance—municipal bonds plus climate grants—is speeding procurement. The metric: lives kept safe during the next heat wave.
''',
    author: mockAuthors[2],
    coverImageUrl: 'https://picsum.photos/seed/article-9/800/600',
    tags: ['Cities', 'Climate'],
    readingTimeMinutes: 5,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-04T07:25:00Z'),
    updatedAt: DateTime.parse('2026-01-04T07:25:00Z'),
  ),
  Article(
    id: 'article-10',
    title: 'Quantum-Safe Encryption Trials Move to Production',
    summary:
        'Hybrid PQC pilots are moving to production as banks hedge against post-quantum risks with measurable insurance.',
    body: '''
Banks and health networks are moving from labs to **production pilots** with hybrid key exchange, hedging against post-quantum risks.

## The hybrid approach
Classical + PQC algorithms run in parallel, preserving interoperability while testing performance ceilings.

### Performance notes
- Latency bumps are acceptable on back-office pipes.
- Front-end sessions need smart fallback to avoid UX hits.

> “This is insurance you can measure,” says CISO Malik Sorensen.

## What’s next
Vendor contracts now bake in PQC roadmaps. The winners will offer seamless rollovers once NIST finalizes standards—without forcing user retraining.
''',
    author: mockAuthors[1],
    coverImageUrl: 'https://picsum.photos/seed/article-10/800/600',
    tags: ['Security', 'Quantum'],
    readingTimeMinutes: 12,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-03T12:00:00Z'),
    updatedAt: DateTime.parse('2026-01-03T12:00:00Z'),
  ),
];
