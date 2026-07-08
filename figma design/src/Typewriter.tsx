import { useState, useEffect, useRef } from "react";

const PHRASES = [
  "Hello, world.",
  "The quick brown fox jumps over the lazy dog.",
  "To be, or not to be — that is the question.",
  "In the beginning was the Word.",
  "It was the best of times, it was the worst of times.",
];

const TYPE_SPEED = 48;
const DELETE_SPEED = 24;
const PAUSE_AFTER_TYPE = 1800;
const PAUSE_AFTER_DELETE = 400;

type Phase = "typing" | "pausing" | "deleting" | "waiting";

export default function Typewriter() {
  const [displayed, setDisplayed] = useState("");
  const [phase, setPhase] = useState<Phase>("typing");
  const [phraseIndex, setPhraseIndex] = useState(0);
  const [cursorVisible, setCursorVisible] = useState(true);
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const cursorIntervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // Cursor blink
  useEffect(() => {
    cursorIntervalRef.current = setInterval(() => {
      setCursorVisible((v) => !v);
    }, 530);
    return () => {
      if (cursorIntervalRef.current) clearInterval(cursorIntervalRef.current);
    };
  }, []);

  // Typewriter logic
  useEffect(() => {
    const phrase = PHRASES[phraseIndex];

    if (phase === "typing") {
      if (displayed.length < phrase.length) {
        timeoutRef.current = setTimeout(() => {
          setDisplayed(phrase.slice(0, displayed.length + 1));
        }, TYPE_SPEED);
      } else {
        timeoutRef.current = setTimeout(() => setPhase("pausing"), PAUSE_AFTER_TYPE);
      }
    } else if (phase === "pausing") {
      setPhase("deleting");
    } else if (phase === "deleting") {
      if (displayed.length > 0) {
        timeoutRef.current = setTimeout(() => {
          setDisplayed((d) => d.slice(0, -1));
        }, DELETE_SPEED);
      } else {
        timeoutRef.current = setTimeout(() => {
          setPhraseIndex((i) => (i + 1) % PHRASES.length);
          setPhase("typing");
        }, PAUSE_AFTER_DELETE);
      }
    }

    return () => {
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, [displayed, phase, phraseIndex]);

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: "3rem",
        width: "100%",
        maxWidth: 720,
      }}
    >
      {/* Terminal label */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: "0.5rem",
          opacity: 0.4,
        }}
      >
        <span style={{ color: "#ff5f57", fontSize: 10, letterSpacing: 2, fontFamily: "monospace" }}>●</span>
        <span style={{ color: "#febc2e", fontSize: 10, letterSpacing: 2, fontFamily: "monospace" }}>●</span>
        <span style={{ color: "#28c840", fontSize: 10, letterSpacing: 2, fontFamily: "monospace" }}>●</span>
        <span
          style={{
            marginLeft: "0.75rem",
            color: "#555",
            fontSize: 11,
            fontFamily: "monospace",
            letterSpacing: "0.12em",
            textTransform: "uppercase",
          }}
        >
          typewriter.sh
        </span>
      </div>

      {/* Main text area */}
      <div
        style={{
          position: "relative",
          width: "100%",
          border: "1px solid #1e1e24",
          borderRadius: 8,
          background: "#111114",
          padding: "2.5rem 2.75rem",
          boxShadow: "0 0 0 1px #ffffff06, 0 24px 60px rgba(0,0,0,0.6)",
        }}
      >
        {/* Scanline overlay */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: 8,
            background:
              "repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,0,0,0.07) 2px, rgba(0,0,0,0.07) 4px)",
            pointerEvents: "none",
          }}
        />

        <div
          style={{
            fontSize: "clamp(1.25rem, 3vw, 1.75rem)",
            lineHeight: 1.5,
            color: "#c8ffc8",
            letterSpacing: "0.03em",
            minHeight: "2.625em",
            display: "flex",
            alignItems: "center",
            gap: 1,
            position: "relative",
            zIndex: 1,
          }}
        >
          <span>{displayed}</span>
          <span
            style={{
              display: "inline-block",
              width: "0.55em",
              height: "1.15em",
              background: "#c8ffc8",
              marginLeft: 2,
              borderRadius: 1,
              opacity: cursorVisible ? 1 : 0,
              transition: "opacity 0.08s",
              verticalAlign: "text-bottom",
            }}
          />
        </div>
      </div>

      {/* Phrase indicators */}
      <div style={{ display: "flex", gap: "0.5rem" }}>
        {PHRASES.map((_, i) => (
          <span
            key={i}
            style={{
              width: i === phraseIndex ? 20 : 6,
              height: 6,
              borderRadius: 3,
              background: i === phraseIndex ? "#c8ffc8" : "#2a2a30",
              transition: "width 0.3s ease, background 0.3s ease",
              display: "inline-block",
            }}
          />
        ))}
      </div>
    </div>
  );
}
