import { createFileRoute } from "@tanstack/react-router";
import {
  ArrowLeft,
  Barcode,
  Boxes,
  Check,
  ChevronLeft,
  CircleDollarSign,
  Home,
  Minus,
  Plus,
  QrCode,
  ScanLine,
  Search,
  Trash2,
  Users,
  WalletCards,
  X,
} from "lucide-react";
import { useMemo, useState, type ReactNode } from "react";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "HotLine — إدارة المتجر" },
      { name: "description", content: "واجهة عربية بسيطة لإدارة المنتجات والمبيعات والديون." },
      { property: "og:title", content: "HotLine — إدارة المتجر" },
      { property: "og:description", content: "إدارة المخزون والمبيعات والديون عبر QR والباركود." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: HotLineApp,
});

type View = "home" | "inventory" | "finance" | "debts" | "create" | "scan" | "product" | "debt";
type Product = { id: number; name: string; price: number; stock: number; kind: "QR" | "Barcode" };
type Debt = { id: number; name: string; total: number; paid: number };

const defaultProduct: Product = { id: 1, name: "قهوة تركي 200 جم", price: 185, stock: 24, kind: "Barcode" };
const defaultDebt: Debt = { id: 1, name: "أحمد سمير", total: 1200, paid: 450 };

const initialProducts: Product[] = [
  defaultProduct,
  { id: 2, name: "مياه معدنية 600 مل", price: 12, stock: 86, kind: "QR" },
  { id: 3, name: "شاي ناعم 250 جم", price: 78, stock: 4, kind: "Barcode" },
];

const initialDebts: Debt[] = [
  defaultDebt,
  { id: 2, name: "محمود فتحي", total: 800, paid: 200 },
  { id: 3, name: "سارة خالد", total: 600, paid: 600 },
];

function HotLineApp() {
  const [view, setView] = useState<View>("home");
  const [products, setProducts] = useState(initialProducts);
  const [debts, setDebts] = useState(initialDebts);
  const [selectedProduct, setSelectedProduct] = useState<Product>(defaultProduct);
  const [selectedDebt, setSelectedDebt] = useState<Debt>(defaultDebt);
  const [dialog, setDialog] = useState<"none" | "addProduct" | "addDebt" | "pay" | "sell">("none");
  const [toast, setToast] = useState("");

  const notify = (message: string) => {
    setToast(message);
    window.setTimeout(() => setToast(""), 2200);
  };

  const openProduct = (product: Product) => {
    setSelectedProduct(product);
    setView("product");
  };

  const openDebt = (debt: Debt) => {
    setSelectedDebt(debt);
    setView("debt");
  };

  const addProduct = (data: FormData) => {
    const name = String(data.get("name") ?? "").trim();
    const price = Number(data.get("price"));
    const stock = Number(data.get("stock"));
    if (!name || price <= 0 || stock < 0) return;
    setProducts((current) => [{ id: Date.now(), name, price, stock, kind: "QR" }, ...current]);
    setDialog("none");
    notify("تم حفظ المنتج في المخزون");
  };

  const content: Record<View, ReactNode> = {
    home: <HomeView products={products} debts={debts} onNavigate={setView} onAdd={() => setDialog("addProduct")} />,
    inventory: <InventoryView products={products} onOpen={openProduct} onAdd={() => setDialog("addProduct")} />,
    finance: <FinanceView debts={debts} />,
    debts: <DebtsView debts={debts} onOpen={openDebt} onAdd={() => setDialog("addDebt")} />,
    create: <CreateCodeView onBack={() => setView("home")} onCreate={() => setDialog("addProduct")} />,
    scan: <ScanView onBack={() => setView("home")} onResult={() => openProduct(products[0] ?? defaultProduct)} />,
    product: <ProductView product={selectedProduct} onBack={() => setView("inventory")} onSell={() => setDialog("sell")} onDelete={() => { setProducts((p) => p.filter((x) => x.id !== selectedProduct.id)); setView("inventory"); notify("تم حذف المنتج"); }} />,
    debt: <DebtView debt={selectedDebt} onBack={() => setView("debts")} onPay={() => setDialog("pay")} />,
  };

  return (
    <main dir="rtl" className="min-h-screen bg-background text-foreground">
      <div className="mx-auto min-h-screen max-w-md border-x border-border bg-background pb-24 shadow-app">
        {content[view]}
        {(["home", "inventory", "finance", "debts"] as View[]).includes(view) && <BottomNav view={view} onNavigate={setView} />}
      </div>
      {dialog !== "none" && (
        <Dialog title={dialog === "addProduct" ? "إضافة منتج" : dialog === "addDebt" ? "إضافة دين" : dialog === "pay" ? "تسجيل دفعة" : "تأكيد البيع"} onClose={() => setDialog("none")}>
          {dialog === "addProduct" && <SimpleForm fields={["name", "price", "stock"]} labels={["اسم المنتج", "السعر بالجنيه", "الكمية"]} onSubmit={addProduct} submit="حفظ وإنشاء QR" />}
          {dialog === "addDebt" && <SimpleForm fields={["name", "amount"]} labels={["اسم العميل", "قيمة الدين"]} submit="حفظ الدين" onSubmit={(data) => { const name = String(data.get("name") ?? ""); const total = Number(data.get("amount")); if (name && total > 0) setDebts((d) => [{ id: Date.now(), name, total, paid: 0 }, ...d]); setDialog("none"); notify("تم تسجيل الدين"); }} />}
          {dialog === "pay" && <SimpleForm fields={["amount"]} labels={["قيمة الدفعة"]} submit="تسجيل الدفعة" onSubmit={(data) => { const amount = Number(data.get("amount")); const remaining = selectedDebt.total - selectedDebt.paid; if (amount > 0 && amount <= remaining) { setDebts((items) => items.map((d) => d.id === selectedDebt.id ? { ...d, paid: d.paid + amount } : d)); setSelectedDebt((d) => ({ ...d, paid: d.paid + amount })); notify("تم تسجيل الدفعة"); } setDialog("none"); }} />}
          {dialog === "sell" && <div className="space-y-3"><p className="text-sm text-muted-foreground">اختر طريقة تسجيل بيع {selectedProduct.name}.</p><PrimaryButton onClick={() => { setDialog("none"); notify("تم تسجيل البيع المدفوع"); }}><CircleDollarSign size={18} /> بيع مدفوع</PrimaryButton><SecondaryButton onClick={() => { setDialog("none"); notify("تم تسجيل البيع كدين"); }}><Users size={18} /> تسجيل كدين</SecondaryButton></div>}
        </Dialog>
      )}
      {toast && <div className="fixed bottom-24 left-1/2 z-50 flex -translate-x-1/2 items-center gap-2 rounded-md bg-success px-4 py-3 text-sm font-bold text-success-foreground shadow-lg"><Check size={17} />{toast}</div>}
    </main>
  );
}

function Header({ title = "HotLine", back }: { title?: string; back?: () => void }) {
  return <header className="sticky top-0 z-10 flex h-16 items-center justify-between border-b border-border bg-background/95 px-5 backdrop-blur"><div className="w-9">{back && <IconButton label="رجوع" onClick={back}><ArrowLeft size={20} /></IconButton>}</div><h1 className="font-display text-xl font-bold">{title}</h1><div className="w-9" /></header>;
}

function HomeView({ products, debts, onNavigate, onAdd }: { products: Product[]; debts: Debt[]; onNavigate: (view: View) => void; onAdd: () => void }) {
  const stock = products.reduce((sum, p) => sum + p.stock, 0);
  const debt = debts.reduce((sum, d) => sum + d.total - d.paid, 0);
  return <><Header /><div className="space-y-7 px-5 pt-6"><section><p className="text-sm text-muted-foreground">مساء الخير</p><h2 className="mt-1 text-2xl font-bold">إدارة متجرك بسهولة</h2></section><section className="grid grid-cols-3 gap-2"><Metric label="مبيعات اليوم" value="4,280" suffix="ج.م" tone="success" /><Metric label="المخزون" value={String(stock)} suffix="قطعة" tone="info" /><Metric label="الديون" value={debt.toLocaleString("ar-EG")} suffix="ج.م" tone="warning" /></section><section><SectionTitle title="إجراء سريع" /><div className="mt-3 grid grid-cols-2 gap-3"><Action icon={<ScanLine />} title="مسح كود" note="بيع منتج" primary onClick={() => onNavigate("scan")} /><Action icon={<Plus />} title="إضافة منتج" note="QR أو باركود" onClick={onAdd} /><Action icon={<Boxes />} title="المخزون" note={`${products.length} منتجات`} onClick={() => onNavigate("inventory")} /><Action icon={<Users />} title="الديون" note={`${debts.filter(d => d.total > d.paid).length} حسابات مفتوحة`} onClick={() => onNavigate("debts")} /></div></section><section><SectionTitle title="تنبيه المخزون" action="عرض الكل" onAction={() => onNavigate("inventory")} /><div className="mt-3 divide-y divide-border rounded-md border border-border bg-card">{products.filter(p => p.stock < 10).map(p => <ProductRow key={p.id} product={p} onClick={() => onNavigate("inventory")} />)}</div></section></div></>;
}

function InventoryView({ products, onOpen, onAdd }: { products: Product[]; onOpen: (p: Product) => void; onAdd: () => void }) {
  const [search, setSearch] = useState("");
  const filtered = products.filter((p) => p.name.includes(search));
  return <><Header title="المخزون" /><div className="px-5 pt-5"><div className="flex gap-2"><label className="flex flex-1 items-center gap-2 rounded-md border border-border bg-card px-3"><Search size={18} className="text-muted-foreground" /><input value={search} onChange={(e) => setSearch(e.target.value)} className="w-full bg-transparent py-3 text-sm outline-none" placeholder="ابحث عن منتج" /></label><IconButton label="إضافة منتج" onClick={onAdd} prominent><Plus size={21} /></IconButton></div><p className="my-5 text-sm text-muted-foreground">{filtered.length} منتجات</p><div className="divide-y divide-border rounded-md border border-border bg-card">{filtered.map((p) => <ProductRow key={p.id} product={p} onClick={() => onOpen(p)} />)}</div></div></>;
}

function ProductRow({ product, onClick }: { product: Product; onClick: () => void }) { return <button onClick={onClick} className="flex w-full items-center gap-3 p-4 text-right transition hover:bg-accent"><div className="grid size-10 place-items-center rounded-md bg-secondary text-secondary-foreground">{product.kind === "QR" ? <QrCode size={20} /> : <Barcode size={22} />}</div><div className="min-w-0 flex-1"><p className="truncate font-semibold">{product.name}</p><p className="mt-1 text-xs text-muted-foreground">{product.price} ج.م · <span className={product.stock < 10 ? "text-warning" : ""}>{product.stock} قطعة</span></p></div><ChevronLeft size={18} className="text-muted-foreground" /></button>; }

function FinanceView({ debts }: { debts: Debt[] }) { const debt = debts.reduce((s, d) => s + d.total - d.paid, 0); return <><Header title="المالية" /><div className="space-y-6 px-5 pt-5"><div className="grid grid-cols-3 gap-2"><Metric label="المبيعات" value="18,450" suffix="ج.م" tone="success" /><Metric label="المدفوع" value="14,700" suffix="ج.م" tone="info" /><Metric label="الديون" value={debt.toLocaleString("ar-EG")} suffix="ج.م" tone="warning" /></div><SectionTitle title="آخر المعاملات" /><div className="divide-y divide-border rounded-md border border-border bg-card"><Transaction title="قهوة تركي × 2" date="اليوم، 8:42 م" amount="+370 ج.م" positive /><Transaction title="دفعة من أحمد سمير" date="اليوم، 5:15 م" amount="+250 ج.م" positive /><Transaction title="بيع آجل — محمود" date="أمس، 9:10 م" amount="780 ج.م" /></div></div></>; }

function Transaction({ title, date, amount, positive }: { title: string; date: string; amount: string; positive?: boolean }) { return <div className="flex items-center gap-3 p-4"><div className={`grid size-9 place-items-center rounded-full ${positive ? "bg-success-soft text-success" : "bg-warning-soft text-warning"}`}><WalletCards size={17} /></div><div className="flex-1"><p className="text-sm font-semibold">{title}</p><p className="mt-1 text-xs text-muted-foreground">{date}</p></div><strong className={positive ? "text-success" : "text-warning"}>{amount}</strong></div>; }

function DebtsView({ debts, onOpen, onAdd }: { debts: Debt[]; onOpen: (d: Debt) => void; onAdd: () => void }) { return <><Header title="الديون" /><div className="px-5 pt-5"><PrimaryButton onClick={onAdd}><Plus size={18} /> إضافة دين جديد</PrimaryButton><div className="mt-5 divide-y divide-border rounded-md border border-border bg-card">{debts.map(d => { const remaining = d.total - d.paid; return <button key={d.id} onClick={() => onOpen(d)} className="flex w-full items-center gap-3 p-4 text-right hover:bg-accent"><div className={`grid size-10 place-items-center rounded-full font-bold ${remaining ? "bg-warning-soft text-warning" : "bg-success-soft text-success"}`}>{d.name[0]}</div><div className="flex-1"><p className="font-semibold">{d.name}</p><p className="mt-1 text-xs text-muted-foreground">مدفوع {d.paid} ج.م</p></div><div className="text-left"><p className={remaining ? "font-bold text-warning" : "font-bold text-success"}>{remaining ? `${remaining} ج.م` : "تم السداد"}</p><p className="mt-1 text-xs text-muted-foreground">المتبقي</p></div></button>; })}</div></div></>; }

function ProductView({ product, onBack, onSell, onDelete }: { product: Product; onBack: () => void; onSell: () => void; onDelete: () => void }) { const [quantity, setQuantity] = useState(1); return <><Header title="تفاصيل المنتج" back={onBack} /><div className="space-y-6 px-5 pt-6"><div className="grid h-40 place-items-center rounded-md border border-border bg-code text-code-foreground"><div className="text-center"><Barcode size={150} strokeWidth={1.2} /><p className="font-mono text-xs">6291100123456</p></div></div><div><span className="rounded bg-secondary px-2 py-1 text-xs text-secondary-foreground">{product.kind}</span><h2 className="mt-3 text-2xl font-bold">{product.name}</h2><p className="mt-2 text-muted-foreground">{product.price} جنيه · متاح {product.stock} قطعة</p></div><div className="flex items-center justify-between rounded-md border border-border bg-card p-4"><span className="font-semibold">كمية البيع</span><div className="flex items-center gap-4"><IconButton label="تقليل" onClick={() => setQuantity(Math.max(1, quantity - 1))}><Minus size={18} /></IconButton><strong className="w-6 text-center text-lg">{quantity}</strong><IconButton label="زيادة" onClick={() => setQuantity(Math.min(product.stock, quantity + 1))}><Plus size={18} /></IconButton></div></div><PrimaryButton onClick={onSell}>بيع الآن · {product.price * quantity} ج.م</PrimaryButton><button onClick={onDelete} className="flex w-full items-center justify-center gap-2 py-3 text-sm font-semibold text-destructive"><Trash2 size={17} /> حذف المنتج</button></div></>; }

function DebtView({ debt, onBack, onPay }: { debt: Debt; onBack: () => void; onPay: () => void }) { const remaining = debt.total - debt.paid; return <><Header title={debt.name} back={onBack} /><div className="space-y-6 px-5 pt-6"><div className="grid grid-cols-3 gap-2"><Metric label="الإجمالي" value={String(debt.total)} suffix="ج.م" tone="info" /><Metric label="المدفوع" value={String(debt.paid)} suffix="ج.م" tone="success" /><Metric label="المتبقي" value={String(remaining)} suffix="ج.م" tone="warning" /></div>{remaining > 0 && <PrimaryButton onClick={onPay}>تسجيل دفعة</PrimaryButton>}<SectionTitle title="سجل الدفعات" /><div className="rounded-md border border-border bg-card p-4"><Transaction title="دفعة نقدية" date="12 سبتمبر 2026" amount={`+${debt.paid} ج.م`} positive /></div></div></>; }

function CreateCodeView({ onBack, onCreate }: { onBack: () => void; onCreate: () => void }) { return <><Header title="إنشاء كود" back={onBack} /><div className="space-y-5 px-5 pt-6"><div className="grid grid-cols-2 gap-3"><Action icon={<QrCode />} title="QR Code" note="مناسب للمسح السريع" primary onClick={onCreate} /><Action icon={<Barcode />} title="Barcode" note="Code 128" onClick={onCreate} /></div></div></>; }

function ScanView({ onBack, onResult }: { onBack: () => void; onResult: () => void }) { return <><Header title="مسح الكود" back={onBack} /><div className="px-5 pt-8 text-center"><div className="relative mx-auto grid aspect-square max-w-xs place-items-center overflow-hidden rounded-md bg-camera"><ScanLine size={100} className="text-camera-foreground" /><div className="scan-line absolute inset-x-8 h-0.5 bg-primary" /></div><p className="mt-6 font-semibold">ضع الكود داخل الإطار</p><p className="mt-2 text-sm text-muted-foreground">سيتم التعرف عليه تلقائيًا</p><div className="mt-7"><PrimaryButton onClick={onResult}>محاكاة قراءة منتج</PrimaryButton></div></div></>; }

function Metric({ label, value, suffix, tone }: { label: string; value: string; suffix: string; tone: "success" | "info" | "warning" }) { return <div className="rounded-md border border-border bg-card p-3"><p className="text-[11px] text-muted-foreground">{label}</p><p className={`mt-2 text-lg font-bold text-${tone}`}>{value}</p><p className="text-[10px] text-muted-foreground">{suffix}</p></div>; }
function Action({ icon, title, note, onClick, primary }: { icon: ReactNode; title: string; note: string; onClick: () => void; primary?: boolean }) { return <button onClick={onClick} className={`rounded-md border p-4 text-right transition active:scale-[.98] ${primary ? "border-primary bg-primary text-primary-foreground" : "border-border bg-card hover:bg-accent"}`}><span className="mb-4 block">{icon}</span><strong className="block">{title}</strong><span className={`mt-1 block text-xs ${primary ? "text-primary-foreground/70" : "text-muted-foreground"}`}>{note}</span></button>; }
function SectionTitle({ title, action, onAction }: { title: string; action?: string; onAction?: () => void }) { return <div className="flex items-center justify-between"><h3 className="font-bold">{title}</h3>{action && <button onClick={onAction} className="text-xs font-semibold text-primary">{action}</button>}</div>; }
function PrimaryButton({ children, onClick }: { children: ReactNode; onClick: () => void }) { return <button onClick={onClick} className="flex w-full items-center justify-center gap-2 rounded-md bg-primary px-4 py-3 text-sm font-bold text-primary-foreground transition hover:bg-primary/90 active:scale-[.99]">{children}</button>; }
function SecondaryButton({ children, onClick }: { children: ReactNode; onClick: () => void }) { return <button onClick={onClick} className="flex w-full items-center justify-center gap-2 rounded-md border border-border bg-secondary px-4 py-3 text-sm font-bold text-secondary-foreground">{children}</button>; }
function IconButton({ children, label, onClick, prominent }: { children: ReactNode; label: string; onClick: () => void; prominent?: boolean }) { return <button aria-label={label} title={label} onClick={onClick} className={`grid size-10 shrink-0 place-items-center rounded-md ${prominent ? "bg-primary text-primary-foreground" : "border border-border bg-card text-foreground"}`}>{children}</button>; }

function Dialog({ title, onClose, children }: { title: string; onClose: () => void; children: ReactNode }) { return <div className="fixed inset-0 z-40 grid place-items-end bg-overlay p-3 sm:place-items-center" onMouseDown={onClose}><div dir="rtl" onMouseDown={(e) => e.stopPropagation()} className="w-full max-w-sm rounded-md border border-border bg-popover p-5 text-popover-foreground shadow-xl"><div className="mb-5 flex items-center justify-between"><h2 className="text-lg font-bold">{title}</h2><IconButton label="إغلاق" onClick={onClose}><X size={18} /></IconButton></div>{children}</div></div>; }
function SimpleForm({ fields, labels, submit, onSubmit }: { fields: string[]; labels: string[]; submit: string; onSubmit: (data: FormData) => void }) { return <form action={onSubmit} className="space-y-4">{fields.map((field, i) => <label key={field} className="block text-sm font-semibold">{labels[i]}<input required name={field} type={field === "name" ? "text" : "number"} min={field === "stock" ? 0 : 1} className="mt-2 w-full rounded-md border border-input bg-background px-3 py-3 font-normal outline-none focus:border-primary" /></label>)}<button className="w-full rounded-md bg-primary px-4 py-3 text-sm font-bold text-primary-foreground">{submit}</button></form>; }

function BottomNav({ view, onNavigate }: { view: View; onNavigate: (v: View) => void }) { const items = [{ key: "home" as View, label: "الرئيسية", icon: Home }, { key: "inventory" as View, label: "المخزون", icon: Boxes }, { key: "finance" as View, label: "المالية", icon: WalletCards }, { key: "debts" as View, label: "الديون", icon: Users }]; return <nav className="fixed bottom-0 left-1/2 z-20 grid h-20 w-full max-w-md -translate-x-1/2 grid-cols-4 border-x border-t border-border bg-background/95 px-2 backdrop-blur">{items.map(({ key, label, icon: Icon }) => <button key={key} onClick={() => onNavigate(key)} className={`flex flex-col items-center justify-center gap-1 text-[11px] font-semibold ${view === key ? "text-primary" : "text-muted-foreground"}`}><Icon size={21} /><span>{label}</span></button>)}</nav>; }