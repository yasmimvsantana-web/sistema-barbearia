document.addEventListener('DOMContentLoaded', async () => {
  const token = localStorage.getItem('token');

  if (!token) {
    window.location.href = 'index.html';
    return;
  }

  try {
    const resposta = await fetch('/api/me', {
      headers: { 'Authorization': `Bearer ${token}` }
    });

    if (!resposta.ok) {
      alert('Sessão expirada. Faça login novamente.');
      localStorage.clear();
      window.location.href = 'index.html';
      return;
    }

    const dados = await resposta.json();
    document.getElementById('nomeUsuario').innerText = `Olá, ${dados.usuario.nome}`;
  } catch (error) {
    alert('Erro ao validar sessão.');
    window.location.href = 'index.html';
  }
});

document.getElementById('btnLogout').addEventListener('click', () => {
  localStorage.clear();
  window.location.href = 'index.html';
});
