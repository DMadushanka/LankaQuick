import { useState, useRef, useEffect } from "react";
import { useTheme } from "../theme";
import type { Farmer, Product } from "../data/products";

interface Props {
  farmer: Farmer;
  product: Product;
  onBack: () => void;
}

interface Message {
  id: string;
  from: "user" | "farmer";
  text: string;
  time: string;
  read?: boolean;
}

const INITIAL_MESSAGES: Message[] = [
  {
    id: "m1",
    from: "farmer",
    text: "ආයුබෝවන්! 🙏 Hello! I'm glad you're interested in my produce. How can I help you today?",
    time: "10:24 AM",
    read: true,
  },
  {
    id: "m2",
    from: "user",
    text: "Hi! Are your tomatoes available for delivery to Gampaha this week?",
    time: "10:25 AM",
    read: true,
  },
  {
    id: "m3",
    from: "farmer",
    text: "Yes! I deliver to Gampaha every Tuesday and Friday. Minimum 5 kg for delivery. Would you like to place an order?",
    time: "10:26 AM",
    read: true,
  },
];

const QUICK_REPLIES = [
  "Is this organic?",
  "What's the minimum order?",
  "Can you deliver today?",
  "Do you offer bulk discount?",
];

function now() {
  return new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

export default function FarmerChatScreen({ farmer, product, onBack }: Props) {
  const { theme } = useTheme();
  const [messages, setMessages] = useState<Message[]>(INITIAL_MESSAGES);
  const [input, setInput] = useState("");
  const [typing, setTyping] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, typing]);

  const FARMER_RESPONSES: Record<string, string> = {
    "Is this organic?": `Yes! Our ${product.name} are grown without any chemical pesticides or synthetic fertilizers. We follow traditional farming methods. 🌿`,
    "What's the minimum order?": `The minimum order for ${product.name} is ${product.minOrder} ${product.unit}. For orders above 10 ${product.unit}, I can offer a small discount!`,
    "Can you deliver today?": "I can arrange same-day delivery for orders placed before 11 AM. For today, it might be by evening. Let me check my schedule!",
    "Do you offer bulk discount?": "Absolutely! For orders above 20 kg, I offer a 10% discount. Above 50 kg, we can negotiate a better price. Contact me directly! 😊",
  };

  const sendMessage = (text: string) => {
    if (!text.trim()) return;
    const userMsg: Message = { id: Date.now().toString(), from: "user", text: text.trim(), time: now() };
    setMessages((m) => [...m, userMsg]);
    setInput("");
    setTyping(true);

    setTimeout(() => {
      setTyping(false);
      const response = FARMER_RESPONSES[text.trim()] ||
        `Thank you for your message! I'll get back to you shortly about the ${product.name}. You can also call me directly for faster response. 🌾`;
      const farmerMsg: Message = {
        id: (Date.now() + 1).toString(),
        from: "farmer",
        text: response,
        time: now(),
      };
      setMessages((m) => [...m, farmerMsg]);
    }, 1200 + Math.random() * 600);
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", background: theme.bg, transition: "background 0.35s" }}>
      {/* Chat header */}
      <div style={{
        padding: "8px 16px 12px",
        background: theme.bgHeader,
        borderBottom: `1px solid ${theme.border}`,
        flexShrink: 0, transition: "background 0.35s, border-color 0.35s",
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <button onClick={onBack} style={{
            background: "none", border: "none", cursor: "pointer",
            color: theme.textPrimary, padding: "4px 0", display: "flex", alignItems: "center",
            transition: "color 0.35s",
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
              <polyline points="15 18 9 12 15 6"/>
            </svg>
          </button>

          {/* Farmer avatar */}
          <div style={{ position: "relative" }}>
            <div style={{
              width: 44, height: 44, borderRadius: 14,
              background: `linear-gradient(135deg, ${farmer.avatarColor}, ${farmer.avatarColor}99)`,
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 18, fontWeight: 800, color: "white",
            }}>
              {farmer.avatar}
            </div>
            <div style={{
              position: "absolute", bottom: 1, right: 1,
              width: 11, height: 11, borderRadius: 6,
              background: "#22c55e", border: `2px solid ${theme.bg}`,
              transition: "border-color 0.35s",
            }} />
          </div>

          <div style={{ flex: 1 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
              <span style={{ fontSize: 15, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>
                {farmer.name}
              </span>
              {farmer.verified && (
                <svg width="14" height="14" viewBox="0 0 24 24" fill="#22c55e">
                  <path d="M9 12l2 2 4-4M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"/>
                </svg>
              )}
            </div>
            <div style={{ fontSize: 11, color: "#22c55e", fontWeight: 600 }}>
              Online · {farmer.location}
            </div>
          </div>

          {/* Product pill */}
          <div style={{
            display: "flex", alignItems: "center", gap: 6,
            background: theme.bgCard, border: `1px solid ${theme.border}`,
            borderRadius: 10, padding: "5px 10px",
            transition: "background 0.35s, border-color 0.35s",
          }}>
            <img src={product.image} alt={product.name} style={{ width: 24, height: 24, borderRadius: 6, objectFit: "cover" }} />
            <div>
              <div style={{ fontSize: 9, color: theme.textMuted, lineHeight: 1, transition: "color 0.35s" }}>Re:</div>
              <div style={{ fontSize: 10, fontWeight: 700, color: theme.textPrimary, maxWidth: 60, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", transition: "color 0.35s" }}>
                {product.name}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div style={{ flex: 1, overflowY: "auto", scrollbarWidth: "none", padding: "16px 16px 8px" }}>
        {/* Date divider */}
        <div style={{ textAlign: "center", marginBottom: 16 }}>
          <span style={{
            fontSize: 11, color: theme.textMuted, fontWeight: 500,
            background: theme.bgCard, padding: "4px 12px", borderRadius: 20,
            transition: "background 0.35s, color 0.35s",
          }}>
            Today
          </span>
        </div>

        {messages.map((msg) => {
          const isUser = msg.from === "user";
          return (
            <div
              key={msg.id}
              className="animate-fade-up"
              style={{
                display: "flex",
                flexDirection: isUser ? "row-reverse" : "row",
                gap: 8,
                marginBottom: 12,
                alignItems: "flex-end",
              }}
            >
              {!isUser && (
                <div style={{
                  width: 28, height: 28, borderRadius: 9, flexShrink: 0,
                  background: `linear-gradient(135deg, ${farmer.avatarColor}, ${farmer.avatarColor}99)`,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 11, fontWeight: 800, color: "white",
                }}>
                  {farmer.avatar}
                </div>
              )}
              <div style={{ maxWidth: "75%" }}>
                <div style={{
                  padding: "10px 14px",
                  borderRadius: isUser ? "16px 16px 4px 16px" : "16px 16px 16px 4px",
                  background: isUser
                    ? "linear-gradient(135deg, #22c55e, #16a34a)"
                    : theme.bgCard,
                  border: isUser ? "none" : `1px solid ${theme.border}`,
                  boxShadow: isUser ? "0 4px 12px rgba(34,197,94,0.25)" : (theme.mode === "light" ? "0 2px 8px rgba(0,0,0,0.07)" : "none"),
                  transition: "background 0.35s",
                }}>
                  <p style={{
                    margin: 0,
                    fontSize: 13,
                    lineHeight: 1.55,
                    color: isUser ? "white" : theme.textPrimary,
                    transition: "color 0.35s",
                  }}>
                    {msg.text}
                  </p>
                </div>
                <div style={{
                  fontSize: 10, color: theme.textMuted,
                  marginTop: 4, transition: "color 0.35s",
                  textAlign: isUser ? "right" : "left",
                  paddingLeft: isUser ? 0 : 2,
                  paddingRight: isUser ? 2 : 0,
                }}>
                  {msg.time}
                  {isUser && <span style={{ marginLeft: 4, color: "#22c55e" }}>✓✓</span>}
                </div>
              </div>
            </div>
          );
        })}

        {/* Typing indicator */}
        {typing && (
          <div style={{ display: "flex", gap: 8, marginBottom: 12, alignItems: "flex-end" }}>
            <div style={{
              width: 28, height: 28, borderRadius: 9, flexShrink: 0,
              background: `linear-gradient(135deg, ${farmer.avatarColor}, ${farmer.avatarColor}99)`,
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 11, fontWeight: 800, color: "white",
            }}>
              {farmer.avatar}
            </div>
            <div style={{
              padding: "12px 16px",
              borderRadius: "16px 16px 16px 4px",
              background: theme.bgCard,
              border: `1px solid ${theme.border}`,
              display: "flex", gap: 4, alignItems: "center",
              transition: "background 0.35s, border-color 0.35s",
            }}>
              {[0, 1, 2].map((i) => (
                <div key={i} style={{
                  width: 6, height: 6, borderRadius: 3,
                  background: theme.textMuted,
                  animation: `typingDot 1.2s ease-in-out ${i * 0.2}s infinite`,
                }} />
              ))}
            </div>
          </div>
        )}

        <div ref={bottomRef} />
      </div>

      {/* Quick replies */}
      <div style={{ padding: "0 16px 8px", display: "flex", gap: 8, overflowX: "auto", scrollbarWidth: "none" }}>
        {QUICK_REPLIES.map((qr) => (
          <button
            key={qr}
            onClick={() => sendMessage(qr)}
            style={{
              flexShrink: 0, padding: "6px 12px", borderRadius: 20,
              border: `1px solid ${theme.border}`,
              background: theme.bgCard, color: theme.textSecondary,
              fontSize: 11, fontWeight: 600, cursor: "pointer", whiteSpace: "nowrap",
              boxShadow: theme.mode === "light" ? "0 1px 5px rgba(0,0,0,0.05)" : "none",
              transition: "background 0.35s, border-color 0.35s, color 0.35s",
            }}
          >
            {qr}
          </button>
        ))}
      </div>

      {/* Input bar */}
      <div style={{
        padding: "8px 16px 14px",
        borderTop: `1px solid ${theme.border}`,
        display: "flex", gap: 10, alignItems: "flex-end",
        background: theme.navBg, backdropFilter: "blur(20px)",
        flexShrink: 0, transition: "background 0.35s, border-color 0.35s",
      }}>
        <div style={{
          flex: 1, background: theme.bgInput, border: `1px solid ${theme.border}`,
          borderRadius: 20, padding: "10px 16px", display: "flex", alignItems: "center", gap: 8,
          transition: "background 0.35s, border-color 0.35s",
        }}>
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && sendMessage(input)}
            placeholder={`Message ${farmer.name.split(" ")[0]}...`}
            style={{
              flex: 1, background: "none", border: "none", outline: "none",
              color: theme.textPrimary, fontSize: 13, fontFamily: "inherit",
            }}
          />
          <button style={{
            background: "none", border: "none", cursor: "pointer",
            color: theme.textMuted, display: "flex", alignItems: "center",
            transition: "color 0.35s",
          }}>
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"/>
            </svg>
          </button>
        </div>
        <button
          onClick={() => sendMessage(input)}
          disabled={!input.trim()}
          style={{
            width: 44, height: 44, borderRadius: 14, border: "none", flexShrink: 0,
            background: input.trim() ? "linear-gradient(135deg, #22c55e, #16a34a)" : theme.bgCard,
            display: "flex", alignItems: "center", justifyContent: "center",
            cursor: input.trim() ? "pointer" : "default",
            boxShadow: input.trim() ? "0 4px 14px rgba(34,197,94,0.35)" : "none",
            transition: "all 0.2s",
          }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={input.trim() ? "white" : theme.textMuted} strokeWidth="2.5" strokeLinecap="round">
            <line x1="22" y1="2" x2="11" y2="13"/>
            <polygon points="22 2 15 22 11 13 2 9 22 2"/>
          </svg>
        </button>
      </div>

      <style>{`
        @keyframes typingDot {
          0%, 100% { transform: translateY(0); opacity: 0.4; }
          50% { transform: translateY(-4px); opacity: 1; }
        }
      `}</style>
    </div>
  );
}
