import crypto from "crypto";

function getKey() {
  const b64 = process.env.FIELD_ENCRYPTION_KEY_BASE64;
  if (!b64 || b64.startsWith("REPLACE_WITH")) return null;
  const key = Buffer.from(b64, "base64");
  if (key.length !== 32) throw new Error("FIELD_ENCRYPTION_KEY_BASE64 must be 32 bytes base64 (AES-256-GCM)");
  return key;
}

export function encryptOptional(plaintext) {
  const key = getKey();
  if (!key) return plaintext ?? null; // fallback: store as-is (prototype)
  if (plaintext == null) return null;

  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);
  const enc = Buffer.concat([cipher.update(String(plaintext), "utf8"), cipher.final()]);
  const tag = cipher.getAuthTag();

  // format: base64(iv).base64(tag).base64(ciphertext)
  return `${iv.toString("base64")}.${tag.toString("base64")}.${enc.toString("base64")}`;
}

export function decryptOptional(payload) {
  const key = getKey();
  if (!key) return payload ?? null;
  if (payload == null) return null;

  const parts = String(payload).split(".");
  if (parts.length !== 3) return payload; // not encrypted
  const [ivB64, tagB64, ctB64] = parts;

  const iv = Buffer.from(ivB64, "base64");
  const tag = Buffer.from(tagB64, "base64");
  const ct = Buffer.from(ctB64, "base64");

  const decipher = crypto.createDecipheriv("aes-256-gcm", key, iv);
  decipher.setAuthTag(tag);
  const dec = Buffer.concat([decipher.update(ct), decipher.final()]);
  return dec.toString("utf8");
}
