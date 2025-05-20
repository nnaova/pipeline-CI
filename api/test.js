const request = require('supertest');
const app = require('./index');

describe('API Endpoints', () => {
  it('should return API status', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('status');
  });

  it('should return all sensors', async () => {
    const res = await request(app).get('/api/sensors');
    expect(res.statusCode).toEqual(200);
    expect(Array.isArray(res.body)).toBeTruthy();
  });

  it('should return a sensor by id', async () => {
    const res = await request(app).get('/api/sensors/1');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('id', 1);
  });

  it('should create a new sensor', async () => {
    const newSensor = {
      name: 'Test Sensor',
      location: 'Test Location',
      value: 15,
      unit: 'test'
    };
    
    const res = await request(app)
      .post('/api/sensors')
      .send(newSensor);
      
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('name', 'Test Sensor');
  });
});
