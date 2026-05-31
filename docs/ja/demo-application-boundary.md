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

## Non-goals

- この gem repository に Rails controllers、routes、models、seed data、authorization examples を追加すること
- `docs/mockups/` を playground application に変えること
- application-specific file-manager behavior を TreeView behavior として文書化すること
