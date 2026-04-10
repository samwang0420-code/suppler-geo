export default {
  async fetch(request, env) {
    if (request.method === 'POST') {
      const formData = await request.formData();
      
      const name = formData.get('name');
      const company = formData.get('company');
      const email = formData.get('email');
      const phone = formData.get('phone');
      const location = formData.get('location');
      const service = formData.get('service');
      const message = formData.get('message');

      const emailContent = `
New Contact Form Submission

Name: ${name}
Company: ${company || 'N/A'}
Email: ${email}
Phone: ${phone || 'N/A'}
Location: ${location}
Service: ${service || 'N/A'}

Message:
${message}
      `.trim();

      try {
        const res = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${env.RESEND_API_KEY}`
          },
          body: JSON.stringify({
            from: 'Website Contact <onboarding@resend.dev>',
            to: ['sam.wang0420@gmail.com'],
            subject: `New Lead: ${name} from ${location}`,
            text: emailContent
          })
        });

        const data = await res.json();
        
        if (res.ok) {
          return new Response(JSON.stringify({ success: true, message: 'Email sent!' }), {
            headers: { 'Content-Type': 'application/json' }
          });
        } else {
          return new Response(JSON.stringify({ error: data.message }), { status: 500 });
        }
      } catch (e) {
        return new Response(JSON.stringify({ error: e.message }), { status: 500 });
      }
    }
    
    return new Response('OK', { status: 200 });
  }
};
