# Generate Nutritional Audit

This Edge Function calls Gemini server-side and returns the nutritional audit
JSON used by the Flutter report screen.

Required secrets:

```sh
supabase secrets set GEMINI_API_KEY="your-rotated-key"
supabase secrets set GEMINI_MODEL="gemini-2.5-flash"
```

Deploy:

```sh
supabase functions deploy generate-nutritional-audit
```
