const nodemailer = require('nodemailer');
const twilio = require('twilio');
const logger = require('./logger');

// Email transporter
const emailTransporter = nodemailer.createTransporter({
  host: process.env.EMAIL_HOST,
  port: process.env.EMAIL_PORT,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Twilio client
const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

const sendEmail = async ({ to, subject, template, data }) => {
  try {
    const emailTemplates = {
      'email-verification': {
        subject: 'Verify Your Email - Smart Social Platform',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2>Welcome to Smart Social Platform!</h2>
            <p>Hi ${data.name},</p>
            <p>Please verify your email address by clicking the button below:</p>
            <a href="${data.verificationUrl}" style="background: #6C5CE7; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block;">Verify Email</a>
            <p>If you didn't create this account, please ignore this email.</p>
          </div>
        `
      },
      'login-alert': {
        subject: 'New Login Alert - Smart Social Platform',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2>New Login Detected</h2>
            <p>Hi ${data.name},</p>
            <p>We detected a new login to your account:</p>
            <ul>
              <li>Device: ${data.device}</li>
              <li>Location: ${data.location}</li>
              <li>Time: ${data.time}</li>
            </ul>
            <p>If this wasn't you, please secure your account immediately.</p>
          </div>
        `
      },
      'password-reset': {
        subject: 'Password Reset - Smart Social Platform',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2>Password Reset Request</h2>
            <p>Hi ${data.name},</p>
            <p>Click the button below to reset your password:</p>
            <a href="${data.resetUrl}" style="background: #6C5CE7; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block;">Reset Password</a>
            <p>This link expires in 10 minutes.</p>
          </div>
        `
      }
    };

    const emailTemplate = emailTemplates[template];
    if (!emailTemplate) {
      throw new Error(`Email template '${template}' not found`);
    }

    const mailOptions = {
      from: process.env.EMAIL_FROM || 'Smart Social Platform <noreply@smartsocial.com>',
      to,
      subject: emailTemplate.subject,
      html: emailTemplate.html
    };

    await emailTransporter.sendMail(mailOptions);
    logger.info(`Email sent successfully to ${to}`);
  } catch (error) {
    logger.error('Email sending error:', error);
    throw error;
  }
};

const sendSMS = async (to, message) => {
  try {
    if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
      logger.warn('Twilio credentials not configured, skipping SMS');
      return;
    }

    await twilioClient.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to
    });

    logger.info(`SMS sent successfully to ${to}`);
  } catch (error) {
    logger.error('SMS sending error:', error);
    throw error;
  }
};

module.exports = { sendEmail, sendSMS };