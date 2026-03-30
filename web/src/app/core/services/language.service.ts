import { Injectable, signal, effect } from '@angular/core';
import { TRANSLATIONS, Lang, TranslationKey } from '../i18n/translations';

@Injectable({ providedIn: 'root' })
export class LanguageService {
  lang = signal<Lang>((localStorage.getItem('ijari_lang') as Lang) || 'en');

  constructor() {
    effect(() => {
      const l = this.lang();
      localStorage.setItem('ijari_lang', l);
      document.documentElement.lang = l;
      document.documentElement.dir = l === 'ar' ? 'rtl' : 'ltr';
    });
  }

  setLang(lang: Lang) { this.lang.set(lang); }

  toggleLang() { this.lang.set(this.lang() === 'en' ? 'ar' : 'en'); }

  t(key: TranslationKey): string {
    return TRANSLATIONS[this.lang()][key] ?? key;
  }

  get isRtl() { return this.lang() === 'ar'; }
}
