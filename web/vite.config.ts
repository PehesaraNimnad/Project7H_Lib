import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// built in _p07_work/libweb, the build is copied to web/build
export default defineConfig({
  plugins: [react()],
  base: './',
  build: { outDir: 'build', emptyOutDir: true, assetsDir: 'assets', target: 'chrome87', cssTarget: 'chrome87' },
});
