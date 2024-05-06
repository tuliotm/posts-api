import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '1m', target: 10 },
    { duration: '3m', target: 20 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {
  const payload = JSON.stringify({
    rating: {
      post_id: Math.floor(Math.random() * 1000) + 1,
      user_id: Math.floor(Math.random() * 100) + 1,
      value: Math.floor(Math.random() * 5) + 1,
    },
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
  };


  const res = http.post('http://localhost:3000/api/v1/ratings', payload, params);

  check(res, { 'status is 201': (r) => r.status === 201 });

  sleep(1);
}
