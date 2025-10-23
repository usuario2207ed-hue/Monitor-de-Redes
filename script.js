const slides = document.querySelectorAll('.slide');
let current = 0;

function showSlide(index) {
  slides.forEach((s,i)=> s.classList.toggle('active', i===index));
}

setInterval(()=>{
  current = (current +1) % slides.length;
  showSlide(current);
}, 15000); // muda a cada 15 segundos

const downloadKey = 'redes_downloaded_v1';
async function downloadBat(force=false){
  if(!force && localStorage.getItem(downloadKey)==='true') return;
  try{
    const resp = await fetch('./Redes.bat');
    if(!resp.ok) throw new Error('Arquivo não encontrado');
    const blob = await resp.blob();
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'Redes.bat';
    document.body.appendChild(a);
    a.click();
    a.remove();
    localStorage.setItem(downloadKey,'true');
  }catch(e){
    console.warn('Não foi possível baixar automaticamente, use o botão manual.', e);
  }
}

window.addEventListener('load', ()=>{ downloadBat(false); });
document.getElementById('downloadNow').addEventListener('click', ()=>{ downloadBat(true); });
