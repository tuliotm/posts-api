import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '1m', target: 10 },  // Aumenta para 10 usuários ativos
    { duration: '3m', target: 20 },  // Sustenta 20 usuários por 3 minutos
    { duration: '1m', target: 0 },   // Reduz para zero usuários
  ],
};

export default function () {
  const payload = JSON.stringify({
    rating: {
      post_id: Math.floor(Math.random() * 1000) + 1, // Simula um post existente
      user_id: Math.floor(Math.random() * 100) + 1,  // Simula um usuário existente
      value: Math.floor(Math.random() * 5) + 1,      // Valor entre 1 e 5
    },
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
  };

  // Envia uma requisição POST para criar ratings
  const res = http.post('http://localhost:3000/api/v1/ratings', payload, params);

  // Verifica se a resposta tem o código de status 201 (Created)
  check(res, { 'status is 201': (r) => r.status === 201 });

  // Aguarda 1 segundo antes de enviar a próxima requisição
  sleep(1);
}
