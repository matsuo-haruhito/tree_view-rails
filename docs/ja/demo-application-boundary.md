# Demo application boundary

TreeView は、再利用できる tree rendering primitives をこの gem repository に置きます。CRUD、authorization、seed data、product-specific workflow まで含む end-to-end の Rails application example は、この repository の外に置き、gem docs が host app 実装例として膨らみすぎないようにします。

## Static mockup と real demo app の違い

Rails を起動せずに baseline DOM structure、CSS hooks、ARIA placement、代表的な interaction state を確認したい場合は、static な [TreeView mockups](../mockups/README.md) を使います。

routes、controllers、database records、authorization、Turbo responses、seed data、complete host-app workflow が必要な例は、real Rails demo application 側で扱います。

## Link policy

Demo repository が public になるまでは、この gem の public docs から demo repository へ直接 link しません。それまでは public entry point を次に限定します。

- visual / DOM reference としての static mockups
- 再利用できる TreeView API / hooks の feature guide
- CRUD、authorization、routes、business actions に関する host-app responsibility boundary

Public demo repository が利用できる状態になったら、root README または docs index から短い link を追加します。その場合も、demo app は example host application であり、TreeView gem contract そのものではないことを明確にします。

## Publication checklist

Demo repository が public になったら、gem contract と example host app の違いを読者が判断するための docs entry point だけを更新します。

更新候補:

- root `README.md`: 既存の mockup / demo boundary の説明近くに短い link を 1 つ追加する。
- root `docs/README.md`: static mockups や言語別 docs と並べて有用な場合だけ、optional entry point として demo app を追加する。
- `docs/en/README.md` と `docs/ja/README.md`: demo app 側の docs がその読者向けに読める状態になっている場合だけ、言語別 link を追加する。
- このページ: temporary な "public になるまで" の表現を link つきに置き換え、example host app である境界を残す。

更新しないもの:

- `docs/mockups/README.md` を、mockups が demo app に変わるかのようには更新しない。この page は static HTML/CSS review asset に集中させる。
- 再利用できる TreeView API を説明する feature guide。demo app が既に文書化済みの feature を示す場合だけ、必要最小限の導線に留める。
- Public API、release、package docs。demo app は gem compatibility contract ではない。

Link を追加する前に、repository が public であること、linked README が private access なしで読めること、CRUD、authorization、seed data、host-app workflow を TreeView gem behavior として約束していないことを確認してください。

## Non-goals

- この gem repository に Rails controllers、routes、models、seed data、authorization examples を追加すること
- `docs/mockups/` を playground application に変えること
- application-specific file-manager behavior を TreeView behavior として文書化すること
