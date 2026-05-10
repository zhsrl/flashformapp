import { VercelRequest, VercelResponse } from '@vercel/node';

export default async (req: VercelRequest, res: VercelResponse) => {
  const API_KEY = process.env.XPAY_API;
  const baseUrl = 'https://api.xpayment.kz/v1';

  // Получить статус платежа
  if (req.method === 'GET') {
    const { paymentId } = req.query;

    const response = await fetch(`${baseUrl}/payments/${paymentId}`, {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
      },
    });

    const data = await response.json();
    return res.status(response.status).json(data);
  }

  // Создать платеж
  if (req.method === 'POST') {
    const response = await fetch(`${baseUrl}/payments`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(req.body),
    });

    const data = await response.json();
    return res.status(response.status).json(data);
  }

  res.status(405).json({ error: 'Method not allowed' });
};